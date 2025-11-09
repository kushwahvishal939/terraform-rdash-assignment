resource "aws_iam_role" "sa_role" {
  name = "${var.cluster_name}-sa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:rbac-test-sa"
          }
        }
      }
    ]
  })
}

# Example S3 policy
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.cluster_name}-s3-access"
  description = "Allow access to S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.sa_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}