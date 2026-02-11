variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # <<< REPLACE THIS! e.g., us-east-1
}

variable "environment_tag" {
  description = "Environment tag for resources"
  type        = string
  default     = "dev"
}

variable "eks_cluster_name_for_vpc_lookup" {
  description = "Name of the EKS cluster to lookup its VPC (from Lab 14)"
  type        = string
  default     = "aws-default" # <<< REPLACE THIS if you changed EKS cluster name
}

# ... (existing variables) ...

variable "app_version_content" {
  description = "Content to store in the S3 object for app version"
  type        = string
  default     = "initial-version"
}

