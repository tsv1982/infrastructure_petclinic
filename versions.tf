terraform {
  backend "s3" {
    bucket = "temp-terraform"
    key    = "terraform-states/terraform.tfstate"
    region = "eu-central-1"
  }
}