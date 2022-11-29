terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "demoAvailableAZ" {
  state = "available"
}

output "demoAvailableAZ" {
  value = data.aws_availability_zones.demoAvailableAZ.names
}
