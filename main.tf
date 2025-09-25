# main.tf

# -----------------
# IAM Resources for CI/CD
# -----------------

# 1. IAM Policy: Defines what actions GitHub can perform
resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-tf-policy"
  description = "Allows GitHub Actions to manage resources for the webserver project"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Statement 1: General permissions for creating infrastructure (VPC, EC2, IAM)
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "vpc:*",
          "iam:*"
        ],
        Resource = "*"
      },
      # Statement 2: S3 Bucket-level permissions (List/Location for state management)
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::tf-cicd-project-state-329599640344"
      },
      # Statement 3: S3 Object-level permissions (Read/Write state file)
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::tf-cicd-project-state-329599640344/webserver/*"
      },
      # Statement 4: DynamoDB Locking table permissions
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:329599640344:table/terraform-locks" 
        # IMPORTANT: Ensure 'us-east-1' matches your DynamoDB region
      }
    ]
  })
}

# 2. IAM Role: The role GitHub Actions will assume (Fixes 'undeclared resource' error)
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-tf-role"

  # Trust policy that grants permission to GitHub's OIDC provider to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::329599640344:oidc-provider/token.actions.githubusercontent.com" 
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike = {
            # CRITICAL: Your exact repository name
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

# -----------------
# Infrastructure Resources (VPC, Subnet, EC2)
# -----------------

# 4. VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-cicd-vpc"
  }
}

# 5. Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-cicd-public-subnet"
  }
}

# 6. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "terraform-cicd-igw"
  }
}

# 7. Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# 8. Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 9. Security Group (Allow SSH and HTTP)
resource "aws_security_group" "web_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-server-sg"
  }
}

# 10. EC2 Instance (Web Server)
resource "aws_instance" "web_server" {
  ami           = "ami-0886832e6b5c3b9e2" # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]
  key_name      = "newkeypair" # IMPORTANT: Replace with a key pair name that exists in your AWS account

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install -y nginx1
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Web-Server-CI-CD"
  }
}
