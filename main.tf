# Trigger Terraform pipeline
# Explanation: Configure the AWS provider and specify the region.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Explanation: Configure the remote backend for Terraform state.
  # This bucket will store your Terraform state file securely.
  # Replace YOUR_AWS_ACCOUNT_ID and YOUR_AWS_REGION.
  backend "s3" {
    bucket         = "jenkins-terraform-state-694862618269" # <<< REPLACE THIS! Must be globally unique.
    key            = "s3-bucket-infra/terraform.tfstate"
    region         = "us-east-1" # <<< REPLACE THIS!
    encrypt        = true # Encrypt state file at rest
    dynamodb_table = "terraform-lock-table" # For state locking (prevent concurrent applies)
  }
}

provider "aws" {
  region = var.aws_region
}

# Explanation: Get the current AWS caller identity for account ID.
data "aws_caller_identity" "current" {}

# Explanation: Get existing VPC and public subnets from your EKS cluster (Lab 14).
# This ensures our S3 bucket is in the same region.
data "aws_vpc" "existing_vpc" {
  tags = {
    Name = var.eks_cluster_name_for_vpc_lookup # From variables.tf
  }
}

# Explanation: Define the S3 bucket resource.
resource "aws_s3_bucket" "my_jenkins_managed_bucket" {
  bucket = "my-jenkins-managed-bucket-${data.aws_caller_identity.current.account_id}" # Unique bucket name
  acl    = "private" # Keep it private

  versioning {
    enabled = true # Keep versions of objects
  }

  tags = {
    Name = "JenkinsManagedBucket"
    Environment = var.environment_tag # From variables.tf
  }
}

# Explanation: Block public access to the S3 bucket.
resource "aws_s3_bucket_public_access_block" "my_jenkins_managed_bucket_public_access_block" {
  bucket = aws_s3_bucket.my_jenkins_managed_bucket.id

  block_public_acls       = true
  block_public_dre_grants = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Explanation: Output the S3 bucket name.
output "s3_bucket_name" {
  description = "Name of the S3 bucket managed by Jenkins Terraform"
  value       = aws_s3_bucket.my_jenkins_managed_bucket.bucket
}

