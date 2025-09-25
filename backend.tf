# backend.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    # This bucket MUST be created manually beforehand
    bucket         = "tf-cicd-project-state-329599640344" 
    key            = "webserver/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" # This table MUST be created manually beforehand (LockID: String)
  }
}
