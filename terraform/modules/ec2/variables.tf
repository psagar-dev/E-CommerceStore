variable "ami_ec2" {
  description = "Name of the ami"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "dockerhub_username" {
  description = "DockerHub username for pulling images"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret for user service"
  type        = string
  sensitive   = true
}