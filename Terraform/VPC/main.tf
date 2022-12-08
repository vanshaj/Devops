terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = ">=2.7.0"
		}
	}
}

provider "aws" {
	profile = "self"
	region = "ap-south-1"
}

resource "aws_vpc" "main" {
	cidr_block = "10.0.0.0/16"
	tags = {
		Name = "tf_vpc"
	}
}
