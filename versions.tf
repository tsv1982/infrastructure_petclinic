terraform {
  backend "s3" {
    bucket = "temp-terraform"
    key    = "terraform-states/terraform.tfstate"
    region = var.aws_region
  }
}