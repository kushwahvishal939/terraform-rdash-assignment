#aws configurations
variable "aws_region" {
  description = "The AWS region to deploy all resources into."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID."
  type        = string
}
variable "availability_zones" {
  description = "A list of availability zones to deploy into (e.g., ['us-east-1a', 'us-east-1b'])."
  type        = list(string)
}

#project level variables
variable "project_name" {
  description = "A unique name for the project, used for naming and tagging resources."
  type        = string
}



# VPC/subnets variables
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "database_subnet_cidrs" {
  type = list(string)
}

variable "cache_subnet_cidrs" {
  type = list(string)
}
variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for S3 bucket"
  type        = bool
}

variable "ecr_repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "environment" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "docker_path" {
  type = string
}

variable "cluster_name" {
  type    = string
}

variable "node_instance_type" {
  type    = string
}
variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}
variable "min_size" {
  type    = number
  default = 1
}

variable "eks_admin_users" {
  description = "List of IAM users to be granted EKS admin access"
  type = list(object({
    username = string
    userarn  = string
    groups   = list(string)
  }))
  default = []
}

variable "docker_config_json" {
  type = string
}

variable "app_image_tag" {
  description = "The tag for the Docker image to be deployed."
  type        = string
  default     = "latest"
}
variable "repository_name" {
  description = "The name of the Docker repository."
  type        = string
}