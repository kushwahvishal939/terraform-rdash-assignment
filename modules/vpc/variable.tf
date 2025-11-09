variable "project_name" {
  description = "A unique name for the project, used for naming and tagging resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones to deploy into."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of 2 CIDR blocks for the public subnets (~1,000 IPs = /22)."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of 2 CIDR blocks for the private subnets (~4,000 IPs = /20)."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "A list of 1 CIDR block for the database subnet (~200 IPs = /24)."
  type        = list(string)
}

variable "cache_subnet_cidrs" {
  description = "A list of 1 CIDR block for the cache subnet (~150 IPs = /24)."
  type        = list(string)
}

variable "aws_region" {
  description = "The AWS region to deploy all resources into."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster, used for tagging."
  type        = string
}