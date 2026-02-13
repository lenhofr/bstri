terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "tf-state-bstri-prod-217354297026-us-east-1"
    key            = "bstri/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bstri-prod-tf-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
