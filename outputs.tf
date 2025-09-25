# outputs.tf

output "github_actions_role_arn" {
  description = "ARN of the IAM Role for GitHub Actions to assume"
  value       = aws_iam_role.github_actions_role.arn
}
