terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.23.0"
    }
  }
  backend "s3" {
    bucket = "lambda-tests-terraform-state-bucket"
  }
}

provider "aws" {
  region = var.aws_region
}
