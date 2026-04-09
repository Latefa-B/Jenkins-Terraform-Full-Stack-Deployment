# Jenkins CI/CD - Full Stack Deployment (App & Infra Orchestration)

Jenkins is one of the most widely used and powerful tools in the DevOps world for implementing Continuous Integration (CI) and Continuous Delivery (CD) pipelines. As an open-source automation server, it enables teams to build, test, and deploy software efficiently through automated workflows. Highly extensible by design, Jenkins supports a vast range of plugins that integrate seamlessly with various tools and technologies. It serves as a centralized automation platform that orchestrates and streamlines repetitive tasks involved in software development, such as : Building software (compiling code), Testing software (running automated tests), Deploying software (sending it to servers or Kubernetes clusters) and Monitoring the execution of these tasks. Enhancing productivity, consistency, and delivery speed.

Previously, we have successfully mastered individual tools and integrated them in various ways. In this final, comprehensive lab, you will orchestrate a full-stack CI/CD pipeline using Jenkins that touches every major technology we've covered:

- Source Code Management (Git): For application and infrastructure code.
- Containerization (Docker): For packaging your application.
- Cloud Infrastructure (AWS & Terraform): For provisioning and managing your EKS cluster, RDS, and a small application-specific S3 resource.
- Container Orchestration (Kubernetes): As the deployment target for your application.
- Package Management (Helm): For deploying your application to Kubernetes.
- Automation Server (Jenkins): Orchestrating the entire workflow.
- Scripting: Within the Jenkinsfile for pipeline logic.

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
<img width="644" height="734" alt="1" src="https://github.com/user-attachments/assets/32ba1bd2-d485-4bb3-90ee-531b80045228" />

- Create a dummy file named version_placeholder.txt in the same directory as main.tf. This is needed for filemd5 to work initially. You can put any content in it, like 0.0.0.
- Update jenkins-terraform-infra-repo/variables.tf to include the new variable for the application version content.
- Save all files.
<img width="822" height="468" alt="2" src="https://github.com/user-attachments/assets/fac4aa20-422e-4512-aa3d-53c19e95e8fa" />

- Commit and push these changes to your jenkins-terraform-infra GitHub repository:
cd jenkins-terraform-infra-repo 
git add . 
git commit -m "Add S3 bucket and object for app version tracking" 
git push origin <your-branch-name>
<img width="859" height="266" alt="3" src="https://github.com/user-attachments/assets/66c24b0e-b2b0-4e0f-bee6-f886456c118d" />

- Manually run terraform apply once locally from this directory to provision the new app_version_bucket and app_version_file. This is important so the bucket exists before Jenkins tries to update the object.
<img width="629" height="324" alt="4" src="https://github.com/user-attachments/assets/59c27cb7-5e59-4c2a-9099-fd873f45ab9d" />
<img width="1038" height="860" alt="5" src="https://github.com/user-attachments/assets/5154a68c-d655-472c-8487-9fe1240b5b7f" />
<img width="781" height="456" alt="6" src="https://github.com/user-attachments/assets/d0f0d1c1-597d-42ac-92b6-768619b79e95" />


### Step 2: Update Jenkinsfile for Full Stack Orchestration
We will modify your Jenkinsfile in the jenkins-docker-app repository to orchestrate the entire flow: building the app, pushing to ECR, updating the Terraform-managed S3 object with the new app version, and finally deploying the Helm Chart to EKS. This Jenkinsfile will need to checkout both the application repo and the infrastructure repo. To complete Step 2, follow the instructions below : 
- Navigate to your jenkins-git-app folder locally.
- Open your Jenkinsfile.
- Update the Jenkinsfile with the following content:

* YOUR_DOCKERHUB_USERNAME: Your Docker Hub username.
* YOUR_AWS_ACCOUNT_ID: Your AWS account ID.
* YOUR_AWS_REGION: Your AWS region (e.g., us-east-1).
* YOUR_EKS_CLUSTER_NAME: The name of your EKS cluster (default was my-k8s-cluster).
* YOUR_RDS_ENDPOINT: The rds_endpoint value you obtained from terraform previously.
* YOUR_GITHUB_USERNAME: Your GitHub username.
* YOUR_TERRAFORM_REPO_NAME: The name of your Terraform infrastructure repository.

- Save Jenkinsfile.
<img width="1094" height="880" alt="7" src="https://github.com/user-attachments/assets/e642ea06-0ff5-4581-a3a4-d27b1db7cf02" />
<img width="1003" height="878" alt="8" src="https://github.com/user-attachments/assets/47cdc594-b94c-45c9-a1c4-140330926888" />
<img width="1059" height="884" alt="9" src="https://github.com/user-attachments/assets/536f7f26-3abe-48bb-b24d-dd58dccda503" />

- Commit and push the updated Jenkinsfile to your GitHub repository:
cd jenkins-git-app 
git add . 
git commit -m "Update Jenkinsfile for full stack orchestration" 
git push origin <your-branch-name>
<img width="787" height="283" alt="10" src="https://github.com/user-attachments/assets/96a91f02-3d68-4dcd-9aff-27895f3cf67b" />

### Step 3: Configure Jenkins Pipeline Job
We will ensure the Python-Docker-Pipeline job is configured to use our aws-credentials and is ready for the full stack orchestration. It needs to know about both Git repositories. To complete Step 3, follow the instructions below : 
- Open your web browser and go to your Jenkins Dashboard (http://localhost:8080).
- Click on Python-Docker-Pipeline.
- In the left navigation, click "Configure."
<img width="1446" height="758" alt="11" src="https://github.com/user-attachments/assets/d2433eb6-936b-4dd3-86d4-77c71b19e29c" />


- Ensure "Build Triggers" -> "GitHub hook trigger for GITScm polling" is checked.
- Ensure "Pipeline" -> "Definition:" is "Pipeline script from SCM" and points to your  application Git repository (jenkins-git-app) and Jenkinsfile.
<img width="1428" height="752" alt="12" src="https://github.com/user-attachments/assets/39424ce0-5791-4488-a034-4788edd9839c" />
<img width="1421" height="737" alt="13" src="https://github.com/user-attachments/assets/6ff49232-d5ab-40a7-82fd-370966e9ecad" />
<img width="1413" height="732" alt="14" src="https://github.com/user-attachments/assets/44c893f8-bd4e-47ee-a660-504b9f19553b" />

- Click "Save."

### Step 4: Trigger Pipeline and Verify Full Stack Deployment
Make a small code change and push it. Jenkins will trigger the pipeline, orchestrating the entire build, push, infrastructure update, and deployment process. To complete Step 4, follow the instructions below : 
- Navigate to your jenkins-git-app folder locally.
- Open app.py and make a tiny, harmless change (e.g., update a comment).
- Commit and push this change to GitHub:
cd jenkins-git-app 
git add app.py 
git commit -m "Trigger full stack CI/CD pipeline" 
git push origin <your-branch-name>
<img width="699" height="261" alt="15" src="https://github.com/user-attachments/assets/2513f038-3d4b-4a66-b68b-0f1b5849db62" />


- Observe in Jenkins:
- Go to your Jenkins Dashboard (http://localhost:8080).
- Click on Python-Docker-Pipeline.
<img width="1431" height="596" alt="16" src="https://github.com/user-attachments/assets/af0e642e-2495-478b-ae56-c02da0c49e66" />

**Expected output** : You should see a new build automatically start.
<img width="1423" height="817" alt="17" src="https://github.com/user-attachments/assets/54876622-94a9-4600-ae84-b98be53e9c28" />

- Click on the build number.
- Click "Stage View." You'll see stages like Checkout Application Code, Checkout Terraform Infra Code, Build Docker Image, Push Docker Image to ECR, Update App Version in Infra, and Deploy to EKS with Helm.
<img width="836" height="202" alt="18" src="https://github.com/user-attachments/assets/1f795d07-a8f1-45c1-85e9-d7c20bb9a943" />

- Monitor the console output for each stage. The Update App Version in Infra stage should show Terraform commands, and Deploy to EKS with Helm should show Helm commands.
<img width="927" height="196" alt="19" src="https://github.com/user-attachments/assets/06262878-e27f-4864-baf2-cf688c809947" />
<img width="836" height="196" alt="20" src="https://github.com/user-attachments/assets/0d03386c-5338-4841-835a-48c5045843dd" />
<img width="817" height="191" alt="21" src="https://github.com/user-attachments/assets/426b5d89-572f-4817-bfcc-9587c5a0752e" />
<img width="783" height="200" alt="22" src="https://github.com/user-attachments/assets/21d3509a-bfa9-4ee5-83f2-082bcbb6e654" />
<img width="790" height="191" alt="23" src="https://github.com/user-attachments/assets/d8dcd10e-40fb-45f1-99d7-5738562f3129" />
<img width="784" height="191" alt="24" src="https://github.com/user-attachments/assets/d84e2aa5-c9b4-416a-b252-2fa768d176f7" />
<img width="800" height="193" alt="25" src="https://github.com/user-attachments/assets/dcf7afd7-755d-4c75-9578-c5a51a9355fd" />
<img width="788" height="188" alt="26" src="https://github.com/user-attachments/assets/08fb03fa-59cb-4745-992d-2df5c4b777b7" />
<img width="789" height="187" alt="27" src="https://github.com/user-attachments/assets/d6c0e31e-98d3-44a4-b53f-b583bb481e87" />



- Verify AWS Resource Updates:
- Once the Jenkins build finishes with SUCCESS, open your AWS Console.
- Go to S3. Find your app-version-bucket-YOUR_AWS_ACCOUNT_ID bucket.
<img width="1427" height="616" alt="28" src="https://github.com/user-attachments/assets/d92ef898-20d6-4399-99b2-88609318eacd" />

- Click on it, and then click on current-app-version.txt.
<img width="1425" height="508" alt="29" src="https://github.com/user-attachments/assets/ad7ca88f-13ae-4657-89d2-b8e93ffb0d9c" />

- Click "Open" or "Download." The content should be your latest Jenkins build number (e.g., 1, 2, 3). This confirms Terraform updated the S3 object!
<img width="1416" height="665" alt="30" src="https://github.com/user-attachments/assets/d9588e65-a867-4bba-a02f-18011578b5be" />
<img width="640" height="412" alt="31" src="https://github.com/user-attachments/assets/a69cdfc7-e494-4ef4-832f-8de543b2933c" />

- Verify EKS Deployment:
- Ensure your kubectl is configured to connect to your EKS cluster.
- Check the Helm release: helm list -n default.
<img width="1156" height="199" alt="32" src="https://github.com/user-attachments/assets/acaa7cbc-1af2-4bce-819d-dbc67343d5d8" />

- Get the EXTERNAL-IP (DNS name) of your my-flask-app-release-my-flask-chart service.
- Open your web browser and access http://<ALB_DNS_NAME>.
<img width="1423" height="723" alt="33" src="https://github.com/user-attachments/assets/93010762-9d27-4d33-b739-2931f485b7b0" />
<img width="1039" height="214" alt="34" src="https://github.com/user-attachments/assets/640dd6cc-8997-47fa-9ed1-e96ac5be17cb" />


Congratulations! You've successfully orchestrated a complete end-to-end CI/CD pipeline that manages both application deployments and infrastructure updates using Jenkins, Git, Docker, AWS, Terraform, Kubernetes, and Helm. This is a truly advanced DevOps capability!

### Step 5 : Clean Up (Extremely Crucial!) 
It is absolutely critical to destroy all AWS resources created in this lab and previous labs to avoid incurring significant ongoing costs. To complete Step 5, follow the instructions below : 
- Destroy the Helm release from EKS: helm uninstall my-flask-app-release -n default # Or your namespace
This will delete all Kubernetes resources managed by Helm (Deployment, Service, Pods, and the AWS Load Balancer).
<img width="613" height="69" alt="35" src="https://github.com/user-attachments/assets/b000de9a-e5f0-4f2e-a523-eed53798a412" />

- Delete the Jenkins Pipeline job:
- Open your web browser to the Jenkins Dashboard.
- Click on Python-Docker-Pipeline.
- In the left navigation, click "Delete Pipeline." Confirm the deletion.
 <img width="838" height="421" alt="36" src="https://github.com/user-attachments/assets/8200d6bd-08bd-47fb-b939-85c9a44c8fa7" />


- Remove webhooks from GitHub: Go to your  GitHub repository settings -> "Webhooks." Delete the Jenkins webhook.
<img width="1268" height="338" alt="37" src="https://github.com/user-attachments/assets/a6b01a9c-281f-46af-b59b-f6254d793665" />
<img width="1258" height="320" alt="38" src="https://github.com/user-attachments/assets/fa934f8f-f29e-4d32-b74f-cf8e21b46195" />

- Destroy all AWS infrastructure created by Terraform :
- Navigate to your eks-cluster-terraform folder.
- terraform destroy
- Type yes and press Enter to confirm.
<img width="783" height="113" alt="39" src="https://github.com/user-attachments/assets/87729344-59c7-4bb4-be5d-96d122c2b74e" />


Be patient! This takes a long time.
- Stop and remove Jenkins agent Docker container: docker stop jenkins-agent docker rm jenkins-agent
<img width="587" height="61" alt="41" src="https://github.com/user-attachments/assets/bbd58547-0b18-4943-99b8-5457aca6b324" />

- Stop and remove Jenkins master Docker container and volume (if completely finished) : docker stop jenkins-server docker rm jenkins-server

- Manually delete the S3 bucket and DynamoDB table used for Terraform state: Go to your AWS S3 console, find jenkins-terraform-state-YOUR_AWS_ACCOUNT_ID, and delete it. You might need to empty it first.
<img width="1431" height="462" alt="43" src="https://github.com/user-attachments/assets/c588b008-21fe-4523-bcbe-830cd449778f" />

- Go to your AWS DynamoDB console, find terraform-lock-table, and delete it.
<img width="1435" height="306" alt="44" src="https://github.com/user-attachments/assets/53ae50b1-f3f5-4bdb-bc32-ed628eb119cb" />

### Summary
This breakdown provides a step-by-step guide to Deploying a Full Stack Deployment (App & Infra Orchestration) using Jenkins as a CI/CD engine. By completing this lab, we have built and orchestrated a fully automated CI/CD pipeline that mirrors real-world DevOps practices used in modern engineering teams. This project demonstrated how application code, container images, infrastructure resources, and Kubernetes deployments can all be managed, versioned, and delivered through a single automated workflow powered by Jenkins.

Not only did you successfully integrate tools such as Git, Docker, Terraform, Kubernetes, and Helm, but you also learned how to make them communicate dynamically—passing build numbers, image tags, and environment data across stages to ensure consistent, repeatable deployments. The pipeline you created showcased true end-to-end automation: from source code changes, to Docker image creation, to infrastructure updates, to Helm-based application releases on EKS.

Most importantly, this lab highlighted the power of Infrastructure as Code and pipeline-driven automation, proving how a well-designed CI/CD process can reduce manual steps, prevent configuration drift, accelerate deployments, and provide complete traceability across the entire stack. You now have hands-on experience with a production-grade workflow that brings together everything from application development to cloud infrastructure orchestration—an essential skillset for any DevOps engineer.



