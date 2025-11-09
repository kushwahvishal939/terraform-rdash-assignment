variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "project_name" {
  description = "Project name for tagging."
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for S3 bucket."
  type        = bool
  default     = true
}
