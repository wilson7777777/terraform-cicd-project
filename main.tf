# -----------------
# Infrastructure Resources (VPC, Subnet, EC2)
# -----------------

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-cicd-vpc"
  }
}

# 2. Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-cicd-public-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "terraform-cicd-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# 5. Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 6. Security Group (Allow SSH and HTTP)
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

# 7. EC2 Instance (Web Server)
resource "aws_instance" "web_server" {
  ami           = "ami-053b0d53c27927909" # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]
  key_name      = "your-key-pair-name" # IMPORTANT: Replace with a key pair name that exists in your AWS account

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
