output "iam_role_arn" {
  description = "The ARN of the created IAM role for the service account."
  value       = aws_iam_role.sa_role.arn
}