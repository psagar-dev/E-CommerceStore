output "instance_public_ip" {
  value = aws_instance.ecommerce_server.public_ip
}