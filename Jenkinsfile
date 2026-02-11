pipeline {
    agent {
        label 'docker-agent' // Runs on agent with Terraform + AWS CLI
    }

    environment {
        AWS_REGION      = 'us-east-1'
        AWS_ACCOUNT_ID  = '694862618269'
        // This variable will be passed to Terraform
        TF_VAR_environment_tag = 'dev'
    }

    stages {

        stage('Checkout Terraform Code') {
            steps {
                dir('jenkins-terraform-infra-repo') { // Put Terraform code in this folder
                    git branch: 'latefa-branch', url: 'https://github.com/Latefa-B/jenkins-terraform-infra.git', changelog: false, poll: false
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    script {
                        echo "--- Initializing Terraform ---"
                        sh """
                          terraform init \
                            -backend-config="bucket=jenkins-terraform-state-${AWS_ACCOUNT_ID}" \
                            -backend-config="key=s3-bucket-infra/terraform.tfstate" \
                            -backend-config="region=${AWS_REGION}" \
                            -backend-config="encrypt=true" \
                            -backend-config="dynamodb_table=terraform-lock-table"
                        """
                        echo "--- Terraform Init Complete ---"
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
                    script {
                        echo "--- Running Terraform Plan ---"
                        sh """
                          terraform plan \
                            -out=tfplan.out \
                            -var="aws_region=${AWS_REGION}" \
                            -var="environment_tag=${TF_VAR_environment_tag}"
                        """
                        echo "--- Terraform Plan Complete ---"
                    }
                }
            }
        }

        // Optional Manual Approval (Recommended for Production)
        // stage('Manual Approval for Apply') {
        //     steps {
        //         input message: 'Approve Terraform Apply?', ok: 'Approve'
        //     }
        // }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    script {
                        echo "--- Applying Terraform Changes ---"
                        sh "terraform apply -auto-approve tfplan.out"
                        echo "--- Terraform Apply Complete ---"
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
