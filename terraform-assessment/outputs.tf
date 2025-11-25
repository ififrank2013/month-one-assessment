# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_url" {
  description = "URL to access the web application"
  value       = "http://${aws_lb.main.dns_name}"
}

# Bastion Host Outputs
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_connection_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.bastion.public_ip}"
}

# Web Server Outputs
output "web_server_1_private_ip" {
  description = "Private IP address of web server 1"
  value       = aws_instance.web_1.private_ip
}

output "web_server_2_private_ip" {
  description = "Private IP address of web server 2"
  value       = aws_instance.web_2.private_ip
}

# Database Server Outputs
output "database_server_private_ip" {
  description = "Private IP address of database server"
  value       = aws_instance.database.private_ip
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# Security Group Outputs
output "bastion_security_group_id" {
  description = "ID of bastion security group"
  value       = aws_security_group.bastion.id
}

output "web_security_group_id" {
  description = "ID of web security group"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "ID of database security group"
  value       = aws_security_group.database.id
}

# Access Instructions
output "access_instructions" {
  description = "Instructions for accessing the infrastructure"
  value       = <<-EOT
    ========================================
    TechCorp Infrastructure Access Guide
    ========================================
    
    1. Web Application:
       URL: http://${aws_lb.main.dns_name}
    
    2. Bastion Host:
       SSH: ssh -i your-key.pem ec2-user@${aws_eip.bastion.public_ip}
       Or with password: ssh admin@${aws_eip.bastion.public_ip}
    
    3. Web Servers (via Bastion):
       Server 1: ssh ec2-user@${aws_instance.web_1.private_ip}
       Server 2: ssh ec2-user@${aws_instance.web_2.private_ip}
    
    4. Database Server (via Bastion):
       SSH: ssh ec2-user@${aws_instance.database.private_ip}
       PostgreSQL: psql -h localhost -U postgres -d techcorp_db
    
    ========================================
  EOT
}