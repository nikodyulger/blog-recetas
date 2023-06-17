terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket                 = "backend-terraform-proyectos"
    key                    = "blog-recetas/terraform.tfstate"
    region                 = "eu-south-2"
    skip_region_validation = true
  }
}

provider "aws" {
  alias  = "spain_region"
  region = var.spain_region
}

provider "aws" {
  alias  = "north_virginia_region"
  region = var.north_virginia_region
}
