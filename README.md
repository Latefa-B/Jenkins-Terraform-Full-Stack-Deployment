# Jenkins CI/CD - Full Stack Deployment (App & Infra Orchestration)

Jenkins is one of the most widely used and powerful tools in the DevOps world for implementing Continuous Integration (CI) and Continuous Delivery (CD) pipelines. As an open-source automation server, it enables teams to build, test, and deploy software efficiently through automated workflows. Highly extensible by design, Jenkins supports a vast range of plugins that integrate seamlessly with various tools and technologies. It serves as a centralized automation platform that orchestrates and streamlines repetitive tasks involved in software development, such as : Building software (compiling code), Testing software (running automated tests), Deploying software (sending it to servers or Kubernetes clusters) and Monitoring the execution of these tasks. Enhancing productivity, consistency, and delivery speed.

Previously, we have successfully mastered individual tools and integrated them in various ways. In this final, comprehensive lab, you will orchestrate a full-stack CI/CD pipeline using Jenkins that touches every major technology we've covered:
**- Source Code Management (Git)**: For application and infrastructure code.
**- Containerization (Docker)**: For packaging your application.
**- Cloud Infrastructure (AWS & Terraform)**: For provisioning and managing your EKS cluster, RDS, and a small application-specific S3 resource.
**- Container Orchestration (Kubernetes)**: As the deployment target for your application.
**- Package Management (Helm)**: For deploying your application to Kubernetes.
**- Automation Server (Jenkins)**: Orchestrating the entire workflow.
**- Scripting** : Within the Jenkinsfile for pipeline logic.

This comprehensive step-by-step guide walks you through the process of Deploying a  Full Stack Deployment (App & Infra Orchestration) using Jenkins as a CI/CD engine. In this lab, your Jenkins pipeline will now not only build and deploy your application but also perform a small, version-stamped infrastructure update using Terraform, demonstrating true end-to-end automation of both application and infrastructure changes. The aim of this lab is to learn : 
- How to orchestrate a complex CI/CD pipeline involving multiple Git repositories.
- How to integrate Terraform infrastructure updates directly into an application deployment pipeline.
- How to pass dynamic data (e.g., build number, image tags) across different stages and tools (Docker, Helm, Terraform).
- The concept of Infrastructure as Code (IaC) within an application pipeline.
- The complete end-to-end flow of a full-stack DevOps pipeline.

## Prerequisites
- Jenkins master server and docker-agent should be running and accessible. The docker-agent should have Docker, AWS CLI, kubectl, helm, and terraform installed.
- AWS EKS cluster should be running.
- AWS ECR repository (my-flask-app-repo) should exist.
- AWS RDS PostgreSQL database should be running
- GitHub repository for application code (jenkins-git-app) containing app.py, Dockerfile, my-flask-chart/, and the Jenkinsfile file.
- Your GitHub repository for Terraform infrastructure (jenkins-terraform-infra), which manages the S3 bucket and DynamoDB table for Terraform state.
- AWS credentials configured in Jenkins with sufficient IAM permissions for ECR, EKS, and S3 (for the app-version bucket).
- The S3 bucket and DynamoDB table for Terraform state (jenkins-terraform-state-YOUR_AWS_ACCOUNT_ID and terraform-lock-table) should exist.

## Step-by-step instructions
### Step 1: Prepare Your Terraform Code for Application Versioning
We will modify your jenkins-terraform-infra repository to include a small Terraform resource that manages an S3 object. This S3 object will store the current application version (Jenkins build number), demonstrating how infrastructure can be updated by the application pipeline. To complete Step 1, follow the instructions below : 
- Navigate to your jenkins-terraform-infra-repo folder locally.
- Open main.tf.
- Add a new S3 bucket and an S3 object resource to main.tf. This bucket will store a simple text file with the deployed app version.
- Create a dummy file named version_placeholder.txt in the same directory as main.tf. This is needed for filemd5 to work initially. You can put any content in it, like 0.0.0.
- Update jenkins-terraform-infra-repo/variables.tf to include the new variable for the application version content.
- Save all files.
- Commit and push these changes to your jenkins-terraform-infra GitHub repository:
cd jenkins-terraform-infra-repo 
git add . 
git commit -m "Add S3 bucket and object for app version tracking" 
git push origin <your-branch-name>
- Manually run terraform apply once locally from this directory to provision the new app_version_bucket and app_version_file. This is important so the bucket exists before Jenkins tries to update the object.

## Step 2: Update Jenkinsfile for Full Stack Orchestration
We will modify your Jenkinsfile in the jenkins-docker-app repository to orchestrate the entire flow: building the app, pushing to ECR, updating the Terraform-managed S3 object with the new app version, and finally deploying the Helm Chart to EKS. This Jenkinsfile will need to checkout both the application repo and the infrastructure repo. To complete Step 2, follow the instructions below : 
Navigate to your jenkins-git-app folder locally.
Open your Jenkinsfile.
Update the Jenkinsfile with the following content:
     
YOUR_DOCKERHUB_USERNAME: Your Docker Hub username.
YOUR_AWS_ACCOUNT_ID: Your AWS account ID.
YOUR_AWS_REGION: Your AWS region (e.g., us-east-1).
YOUR_EKS_CLUSTER_NAME: The name of your EKS cluster from Lab 14 (default was my-k8s-cluster).
YOUR_RDS_ENDPOINT: The rds_endpoint value you obtained from terraform apply in Lab 15.
YOUR_GITHUB_USERNAME: Your GitHub username.
YOUR_TERRAFORM_REPO_NAME: The name of your Terraform infrastructure repository.
Save Jenkinsfile.

Commit and push the updated Jenkinsfile to your GitHub repository:
cd jenkins-git-app 
git add . 
git commit -m "Update Jenkinsfile for full stack orchestration" 
git push origin <your-branch-name>

Step 3: Configure Jenkins Pipeline Job
We will ensure the Python-Docker-Pipeline job is configured to use our aws-credentials and is ready for the full stack orchestration. It needs to know about both Git repositories. To complete Step 3, follow the instructions below : 
Open your web browser and go to your Jenkins Dashboard (http://localhost:8080).
Click on Python-Docker-Pipeline.

In the left navigation, click "Configure."

Ensure "Build Triggers" -> "GitHub hook trigger for GITScm polling" is checked.
Ensure "Pipeline" -> "Definition:" is "Pipeline script from SCM" and points to your  application Git repository (jenkins-git-app) and Jenkinsfile.
Click "Save."
Step 4: Trigger Pipeline and Verify Full Stack Deployment
Make a small code change and push it. Jenkins will trigger the pipeline, orchestrating the entire build, push, infrastructure update, and deployment process. To complete Step 4, follow the instructions below : 
Navigate to your jenkins-git-app folder locally.
Open app.py and make a tiny, harmless change (e.g., update a comment).
Commit and push this change to GitHub:
cd jenkins-git-app 
git add app.py 
git commit -m "Trigger full stack CI/CD pipeline" 
git push origin <your-branch-name>


Observe in Jenkins:
Go to your Jenkins Dashboard (http://localhost:8080).
Click on Python-Docker-Pipeline.
You should see a new build automatically start.

Click on the build number.
Click "Stage View." You'll see stages like Checkout Application Code, Checkout Terraform Infra Code, Build Docker Image, Push Docker Image to ECR, Update App Version in Infra, and Deploy to EKS with Helm.
Monitor the console output for each stage. The Update App Version in Infra stage should show Terraform commands, and Deploy to EKS with Helm should show Helm commands.



Verify AWS Resource Updates:
Once the Jenkins build finishes with SUCCESS, open your AWS Console.
Go to S3. Find your app-version-bucket-YOUR_AWS_ACCOUNT_ID bucket.

Click on it, and then click on current-app-version.txt.

Click "Open" or "Download." The content should be your latest Jenkins build number (e.g., 1, 2, 3). This confirms Terraform updated the S3 object!

Verify EKS Deployment:
Ensure your kubectl is configured to connect to your EKS cluster.
Check the Helm release: helm list -n default.
Get the EXTERNAL-IP (DNS name) of your my-flask-app-release-my-flask-chart service.
Open your web browser and access http://<ALB_DNS_NAME>.
Congratulations! You've successfully orchestrated a complete end-to-end CI/CD pipeline that manages both application deployments and infrastructure updates using Jenkins, Git, Docker, AWS, Terraform, Kubernetes, and Helm. This is a truly advanced DevOps capability!
Step 5 : Clean Up (Extremely Crucial!) 
It is absolutely critical to destroy all AWS resources created in this lab and previous labs to avoid incurring significant ongoing costs. To complete Step 5, follow the instructions below : 
Destroy the Helm release from EKS: helm uninstall my-flask-app-release -n default # Or your namespace
This will delete all Kubernetes resources managed by Helm (Deployment, Service, Pods, and the AWS Load Balancer).
Delete the Jenkins Pipeline job:
Open your web browser to the Jenkins Dashboard.
Click on Python-Docker-Pipeline.
In the left navigation, click "Delete Pipeline." Confirm the deletion.

Remove webhooks from GitHub:
Go to your jenkins-git-app GitHub repository settings -> "Webhooks." Delete the Jenkins webhook.
Go to your jenkins-terraform-infra GitHub repository settings -> "Webhooks." Delete the Jenkins webhook.

Destroy all AWS infrastructure created by Terraform (from Lab 14/15/this lab):
Navigate to your eks-cluster-terraform folder.
terraform destroy
Type yes and press Enter to confirm.
Be patient! This takes a long time.
Stop and remove Jenkins agent Docker container:
docker stop jenkins-agent docker rm jenkins-agent

Stop and remove Jenkins master Docker container and volume (if completely finished)
docker stop jenkins-server
docker rm jenkins-server

Manually delete the S3 bucket and DynamoDB table used for Terraform state:
Go to your AWS S3 console, find jenkins-terraform-state-YOUR_AWS_ACCOUNT_ID, and delete it. 
You might need to empty it first.
Go to your AWS DynamoDB console, find terraform-lock-table, and delete it.

Summary
This breakdown provides a step-by-step guide to Deploying a Full Stack Deployment (App & Infra Orchestration) using Jenkins as a CI/CD engine. By completing this lab, we have built and orchestrated a fully automated CI/CD pipeline that mirrors real-world DevOps practices used in modern engineering teams. This project demonstrated how application code, container images, infrastructure resources, and Kubernetes deployments can all be managed, versioned, and delivered through a single automated workflow powered by Jenkins.
Not only did you successfully integrate tools such as Git, Docker, Terraform, Kubernetes, and Helm, but you also learned how to make them communicate dynamically—passing build numbers, image tags, and environment data across stages to ensure consistent, repeatable deployments. The pipeline you created showcased true end-to-end automation: from source code changes, to Docker image creation, to infrastructure updates, to Helm-based application releases on EKS.
Most importantly, this lab highlighted the power of Infrastructure as Code and pipeline-driven automation, proving how a well-designed CI/CD process can reduce manual steps, prevent configuration drift, accelerate deployments, and provide complete traceability across the entire stack. You now have hands-on experience with a production-grade workflow that brings together everything from application development to cloud infrastructure orchestration—an essential skillset for any DevOps engineer.



