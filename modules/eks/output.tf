output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group" {
  value = aws_security_group.cluster.id
}

output "oidc_provider_arn" {
  description = "The ARN of the EKS OIDC Identity Provider."
  value       = aws_iam_openid_connect_provider.rdash_oidc.arn
}

output "oidc_provider_url" {
  description = "The URL of the EKS OIDC Identity Provider."
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "kubeconfig" {
  description = "Kubeconfig content to connect to the EKS cluster."
  sensitive   = true
  value = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.main.endpoint}
    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
  name: ${aws_eks_cluster.main.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.main.name}
    user: aws
  name: ${aws_eks_cluster.main.name}
current-context: ${aws_eks_cluster.main.name}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${aws_eks_cluster.main.name}"
KUBECONFIG
}

output "node_group_arn" {
  description = "ARN of the EKS node group."
  value       = aws_eks_node_group.main.arn
}