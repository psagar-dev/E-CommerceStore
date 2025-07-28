variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "sagar-ecommerce"
}

variable "ami_ec2" {
  description = "Name of the ami"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "dockerhub_username" {
  description = "DockerHub username for pulling images"
  type        = string
  default     = "securelooper"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "sagar-b10"
}

variable "jwt_secret" {
  description = "JWT secret for user service"
  type        = string
  sensitive   = true
}