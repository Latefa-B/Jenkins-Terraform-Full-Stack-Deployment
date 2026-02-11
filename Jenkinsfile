pipeline {
    agent {
        label 'docker-agent' // Ensure this runs on your agent with Terraform, AWS CLI
    }

    environment {
        AWS_REGION = 'us-east-1' // e.g., us-east-1
        AWS_ACCOUNT_ID = '694862618269' // Your AWS Account ID
        # This variable will be passed to Terraform
        TF_VAR_environment_tag = 'dev' // Example: 'dev', 'staging', 'prod'
    }

    stages {
        stage('Checkout Terraform Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials', variable: 'AWS_CREDS')]) {
                    script {
                        echo "--- Initializing Terraform ---"
                        // Set AWS credentials as environment variables for Terraform
                        // AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are automatically set by withCredentials
                        sh "terraform init -backend-config=\"bucket=jenkins-terraform-state-${AWS_ACCOUNT_ID}\" -backend-config=\"key=s3-bucket-infra/terraform.tfstate\" -backend-config=\"region=${AWS_REGION}\" -backend-config=\"encrypt=true\" -backend-config=\"dynamodb_table=terraform-lock-table\""
                        echo "--- Terraform Init Complete ---"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials', variable: 'AWS_CREDS')]) {
                    script {
                        echo "--- Running Terraform Plan ---"
                        // Run terraform plan and save the output to a file
                        sh "terraform plan -out=tfplan.out -var=\"aws_region=${AWS_REGION}\" -var=\"environment_tag=${TF_VAR_environment_tag}\""
                        echo "--- Terraform Plan Complete ---"
                    }
                }
            }
        }

        // Optional: Manual Approval Stage (Highly Recommended for Production)
        // stage('Manual Approval for Apply') {
        //     steps {
        //         input message: 'Approve Terraform Apply?', ok: 'Approve'
        //     }
        // }

        stage('Terraform Apply') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials', variable: 'AWS_CREDS')]) {
                    script {
                        echo "--- Applying Terraform Changes ---"
                        // Apply the saved plan
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

