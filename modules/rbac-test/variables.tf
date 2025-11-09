variable "namespace_a" {
  description = "Name for the first RBAC test namespace."
  type        = string
}

variable "namespace_b" {
  description = "Name for the second RBAC test namespace."
  type        = string
}

variable "service_account_name" {
  description = "Name for the Kubernetes service account."
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for the service account (IRSA)."
  type        = string
}

variable "ecr_repo_url" {
  description = "URL of the ECR repository for the test pod image."
  type        = string
}

variable "app_image_tag" {
  description = "Tag of the test pod image."
  type        = string
  default     = "latest"
}

variable "cluster_name" {
  description = "The name of the EKS cluster. Used to create an explicit dependency."
  type        = string
}

variable "node_group_arn" {
  description = "The ARN of the EKS node group. Used to create an explicit dependency."
  type        = string
}