terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  shared_config_files      = ["/Users/nikodyulger/.aws/config"]
  shared_credentials_files = ["/Users/nikodyulger/.aws/credentials"]
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
