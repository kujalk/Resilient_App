provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "servian-devops-tf"
    key    = "gitaction"
    region  = "ap-southeast-1"
  }
}