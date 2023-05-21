terraform {
  required_version = "~> v1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0" // old version = >= 3.74.0
    }
  }
}
