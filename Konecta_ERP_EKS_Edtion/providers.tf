####################################################################
# providers.tf - Single Region Provider Configuration
####################################################################

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Project     = "Konecta-ERP"
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}