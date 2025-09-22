# Region information
output "server_region" {
  description = "Region where Cyperf server is deployed"
  value       = var.primary_region
}

output "client_region" {
  description = "Region where Cyperf client is deployed"  
  value       = var.secondary_region
}

# Instance IPs
output "CYPERF_SERVER_IP" {
  description = "Public IP of Cyperf server"
  value       = aws_instance.cyperf_server.public_ip
}

output "CYPERF_CLIENT_IP" {
  description = "Public IP of Cyperf client"
  value       = aws_instance.cyperf_client.public_ip
}

output "CYPERF_SERVER_PRIVATE_IP" {
  description = "Private IP of the Cyperf Server"
  value       = aws_instance.cyperf_server.private_ip
}

output "CYPERF_CLIENT_PRIVATE_IP" {
  description = "Private IP of the Cyperf Client"
  value       = aws_instance.cyperf_client.private_ip
}

# Network information
output "primary_vpc_id" {
  description = "VPC ID in primary region"
  value       = aws_vpc.primary_vpc.id
}

output "secondary_vpc_id" {
  description = "VPC ID in secondary region"
  value       = aws_vpc.secondary_vpc.id
}

output "vpc_peering_connection_id" {
  description = "VPC peering connection ID"
  value       = aws_vpc_peering_connection.primary_to_secondary.id
}

# Deployment summary
output "deployment_summary" {
  description = "Complete deployment summary"
  value = {
    server_region        = var.primary_region
    client_region        = var.secondary_region
    instance_type        = var.instance_type
    server_public_ip     = aws_instance.cyperf_server.public_ip
    client_public_ip     = aws_instance.cyperf_client.public_ip
    server_private_ip    = aws_instance.cyperf_server.private_ip
    client_private_ip    = aws_instance.cyperf_client.private_ip
    primary_vpc_id       = aws_vpc.primary_vpc.id
    secondary_vpc_id     = aws_vpc.secondary_vpc.id
    peering_connection   = aws_vpc_peering_connection.primary_to_secondary.id
  }
}

# SSH connection commands
output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    server = "ssh -i ${var.key_name} ubuntu@${aws_instance.cyperf_server.public_ip}"
    client = "ssh -i ${var.key_name} ubuntu@${aws_instance.cyperf_client.public_ip}"
  }
}
