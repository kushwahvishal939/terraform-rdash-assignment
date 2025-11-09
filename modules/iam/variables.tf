variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster."
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket to grant access to."
  type        = string
}

variable "service_account_name" {
  description = "The name of the Kubernetes service account."
  type        = string
  default     = "rbac-test-sa"
}

variable "service_account_namespace" {
  description = "The namespace of the Kubernetes service account."
  type        = string
  default     = "default"
}