# Terraform configuration for AWS provider and backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "jenkins-terraform-state-694862618269" # Globally unique
    key            = "s3-bucket-infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}

# Get current AWS account info
data "aws_caller_identity" "current" {}

# Get existing VPC for reference
data "aws_vpc" "existing_vpc" {
  tags = {
    Name = var.eks_cluster_name_for_vpc_lookup
  }
}

# -----------------------------
# Existing Jenkins-managed S3 bucket
# -----------------------------
resource "aws_s3_bucket" "my_jenkins_managed_bucket" {
  bucket = "my-jenkins-managed-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "JenkinsManagedBucket"
    Environment = var.environment_tag
  }
}

resource "aws_s3_bucket_public_access_block" "my_jenkins_managed_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.my_jenkins_managed_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket managed by Jenkins Terraform"
  value       = aws_s3_bucket.my_jenkins_managed_bucket.bucket
}

# -----------------------------
# New S3 bucket to store application version info
# -----------------------------
resource "aws_s3_bucket" "app_version_bucket" {
  bucket = "app-version-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  tags = {
    Name        = "AppVersionBucket"
    Environment = var.environment_tag
  }
}

resource "aws_s3_bucket_public_access_block" "app_version_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.app_version_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "app_version_file" {
  bucket       = aws_s3_bucket.app_version_bucket.id
  key          = "current-app-version.txt"
  content      = var.app_version_content       # From Jenkins pipeline
  content_type = "text/plain"
  acl          = "private"
  etag         = filemd5("version_placeholder.txt") # Initial placeholder
}

output "app_version_bucket_name" {
  description = "Name of the S3 bucket storing app version"
  value       = aws_s3_bucket.app_version_bucket.bucket
}
