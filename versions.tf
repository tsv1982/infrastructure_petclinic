terraform {
  backend "s3" {
    bucket = "temp-terraform"
    key    = "terraform-states/terraform.tfstate"
    region = "us-east-1"
  }
}