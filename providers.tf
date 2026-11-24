terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "Test"
      ManagedBy   = "Terraform"
    }
  }
}
