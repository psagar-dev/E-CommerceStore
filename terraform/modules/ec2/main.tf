resource "aws_instance" "ecommerce_server" {
  ami                    = var.ami_ec2
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = templatefile("${path.module}/../../user-data.sh", {
    dockerhub_username   = var.dockerhub_username,
    jwt_secret           = var.jwt_secret
  })

  tags = {
    Name = "${var.project_name}-server"
  }

  associate_public_ip_address = true
}