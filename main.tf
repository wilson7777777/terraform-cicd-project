# main.tf snippet: Policy with explicit S3, DDB, and general permissions

resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-tf-policy"
  description = "Allows GitHub Actions to manage resources for the webserver project"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "vpc:*",
          "iam:*" # Added for creating and managing roles/policies
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::tf-cicd-project-state-329599640344"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::tf-cicd-project-state-329599640344/webserver/*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:329599640344:table/terraform-locks" 
        # Ensure 'us-east-1' matches your DynamoDB region
      }
    ]
  })
}
