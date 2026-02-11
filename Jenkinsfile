pipeline {
    agent {
        label 'docker-agent'
    }

    environment {
        AWS_REGION      = 'us-east-1'
        AWS_ACCOUNT_ID  = '694862618269'
        TF_VAR_environment_tag = 'dev'
    }

    stages {

        stage('Checkout Terraform Code') {
            steps {
                dir('jenkins-terraform-infra-repo') {
                    deleteDir()  // ensure clean clone
                    git branch: 'latefa-branch',
                        url: 'https://github.com/Latefa-B/jenkins-terraform-infra.git',
                        changelog: false,
                        poll: false
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    dir('jenkins-terraform-infra-repo') {   // ✅ CRITICAL FIX
                        script {
                            sh 'ls -la'   // debug (optional)

                            echo "--- Initializing Terraform ---"
                            sh """
                              terraform init \
                                -backend-config="bucket=jenkins-terraform-state-${AWS_ACCOUNT_ID}" \
                                -backend-config="key=s3-bucket-infra/terraform.tfstate" \
                                -backend-config="region=${AWS_REGION}" \
                                -backend-config="encrypt=true" \
                                -backend-config="dynamodb_table=terraform-lock-table"
                            """
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    dir('jenkins-terraform-infra-repo') {   // ✅ CRITICAL FIX
                        script {
                            echo "--- Running Terraform Plan ---"
                            sh """
                              terraform plan \
                                -out=tfplan.out \
                                -var="aws_region=${AWS_REGION}" \
                                -var="environment_tag=${TF_VAR_environment_tag}"
                            """
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    dir('jenkins-terraform-infra-repo') {   // ✅ CRITICAL FIX
                        script {
                            echo "--- Applying Terraform Changes ---"
                            sh "terraform apply -auto-approve tfplan.out"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Status: ${currentBuild.result}"
        }
        success {
            echo "Congratulations! Terraform deployment succeeded."
        }
        failure {
            echo "Terraform deployment failed. Please check logs."
        }
    }
}
