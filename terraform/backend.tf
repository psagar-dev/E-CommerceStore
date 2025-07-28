terraform {
  backend "s3" {
    bucket         = "sagar-ecommerce-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "sagar-terraform-locks"
    encrypt        = true
  }
}