module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  aws_region   = var.aws_region
  cluster_name = var.cluster_name
  availability_zones    = data.aws_availability_zones.available.names
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  cache_subnet_cidrs    = var.cache_subnet_cidrs
}

# IAM Role for Service Account (IRSA)
module "iam_for_sa" {
  source            = "./modules/iam"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  s3_bucket_arn     = "arn:aws:s3:::${var.bucket_name}"
}

data "aws_availability_zones" "available" {
  state = "available"
}


# ECR module
module "ecr" {
  source               = "./modules/ecr" # NOTE: This module needs to be created.
  repository_name      = "${var.project_name}-ecr-repo"
  aws_region           = var.aws_region
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  docker_path          = var.docker_path
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# EKS Cluster Module
module "eks" {
  source             = "./modules/eks"
  aws_region         = var.aws_region
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_type = var.node_instance_type
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  eks_admin_users    = var.eks_admin_users
}

module "rbac-test" {
  source               = "./modules/rbac-test"
  namespace_a          = "rbac-a"
  namespace_b          = "rbac-b"
  service_account_name = "rbac-test-sa"
  cluster_name         = module.eks.cluster_name # Add explicit dependency
  node_group_arn       = module.eks.node_group_arn # Add stronger dependency
  iam_role_arn         = module.iam_for_sa.iam_role_arn
  ecr_repo_url         = module.ecr.repository_url
  app_image_tag        = var.app_image_tag
}
