project_name          = "rdash"
vpc_cidr              = "10.0.0.0/16"
aws_region            = "ap-south-1"
availability_zones    = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs   = ["10.0.0.0/22", "10.0.4.0/22"]
private_subnet_cidrs  = ["10.0.16.0/20", "10.0.32.0/20"]
database_subnet_cidrs = ["10.0.64.0/24"]
cache_subnet_cidrs    = ["10.0.65.0/24"]

# Storage configuration
bucket_name       = "production-terraform-state-vishal"
enable_versioning = true

# ECR configuration
ecr_repo_name = "testpod"
environment   = "prod"
docker_path   = "./docker"

#EKS
cluster_name       = "rdash-prod"
node_instance_type = "t3.medium"
desired_capacity   = 2
max_size           = 4
min_size           = 1
aws_account_id     = "715418180138"
repository_name    = "tech-vishal-ecr-repo"
app_image_tag      = "latest"
docker_config_json = "~/.docker/config.json"
eks_admin_users = [
  {
    username = "sayank.jha@devops"
    userarn  = "arn:aws:iam::715418180138:user/sayank.jha@devops"
    groups   = ["system:masters"]
  }
]