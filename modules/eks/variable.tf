variable "aws_region" {
    description = "The AWS region to deploy the EKS cluster in."
    type        = string
}

variable "cluster_name" {
  type    = string
}

variable "vpc_id" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "node_instance_type" {
    type = string
}
variable "desired_capacity" {
    type = number
}

variable "max_size" {
    type = number
}

variable "min_size" {
    type = number
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
