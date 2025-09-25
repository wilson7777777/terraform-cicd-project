# 2. IAM Role: The role GitHub Actions will assume
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-tf-role"

  # Trust policy that grants permission to GitHub's OIDC provider to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # ----------------------------------------------------------------------
          # Your Account ID has been placed here: 329599640344
          # ----------------------------------------------------------------------
          Federated = "arn:aws:iam::329599640344:oidc-provider/token.actions.githubusercontent.com" 
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:your-github-username/your-repo-name:*" # <-- REPLACE with YOUR GitHub user/repo name
          }
        }
      }
    ]
  })
}
