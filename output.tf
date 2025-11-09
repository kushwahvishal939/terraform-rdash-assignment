output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}
output "cache_subnet_ids" {
  value = module.vpc.cache_subnet_ids
}

output "ecr_repository_name" {
  value = module.ecr.repository_name
}

output "ecr_repository_arn" {
  value = module.ecr.repository_arn
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}


output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "iam_role_for_sa_arn" {
  description = "The ARN of the IAM role created for the rbac-test-sa service account."
  value       = module.iam_for_sa.iam_role_arn
}
