# backend.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # This block tells Terraform where to store the state file
  backend "s3" {
    # ----------------------------------------------------
    # !!! CHOOSE A GLOBALLY UNIQUE NAME HERE !!!
    # ----------------------------------------------------
    bucket         = "tf-cicd-project-state-329599640344" 
    key            = "webserver/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" # Used to prevent concurrent state modifications
  }
}
