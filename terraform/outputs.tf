output "frontend_url" {
  value       = "http://${module.ec2.instance_public_ip}:3000"
  description = "Public URL for the frontend service"
}