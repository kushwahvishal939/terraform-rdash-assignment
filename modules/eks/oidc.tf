resource "aws_iam_openid_connect_provider" "rdash_oidc" {
  url            = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]

  # Static SHA-1 thumbprint for EKS OIDC
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0f0c45c62"]
}
