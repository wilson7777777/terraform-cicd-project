# main.tf

# -----------------
# IAM Resources for CI/CD
# -----------------

# 1. IAM Policy: Defines what actions GitHub can perform (Updated with explicit permissions)
resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-tf-policy"
  description = "Allows GitHub Actions to manage resources for the webserver project"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # General resource permissions (VPC and EC2 will be added later)
          "ec2:*",
          "vpc:*",
          
          # Explicit S3/DynamoDB permissions for state management (Fixes 403 error)
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "*"
      },
    ]
  })
}

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
          # Using your AWS Account ID: 329599640344
          Federated = "arn:aws:iam::329599640344:oidc-provider/token.actions.githubusercontent.com" 
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          # Trust Policy condition using your exact repository name
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:wilson7777777/terraform-cicd-project:*" 
          }
        }
      }
    ]
  })
}

# 3. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.github_actions_policy.arn
  role       = aws_iam_role.github_actions_role.name
}
