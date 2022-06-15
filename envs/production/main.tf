provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      project = "hackathon-22-spring-14"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "terraform-tfstate-hackathon22-spring-14"
    region  = "ap-northeast-1"
    key     = "production.terraform.tfstate"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"

    }
  }
}
