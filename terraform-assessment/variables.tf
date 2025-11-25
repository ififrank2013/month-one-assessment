# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet Configuration
variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

# Instance Types
variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "web_instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for database server"
  type        = string
  default     = "t3.small"
}

# Key Pair
variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

# Security
variable "my_ip" {
  description = "Your IP address in CIDR notation (e.g., 203.0.113.25/32) for SSH access to bastion"
  type        = string
}

variable "ssh_password" {
  description = "Password for SSH user authentication (optional, for password-based access)"
  type        = string
  default     = "TechCorp2024!Secure"
  sensitive   = true
}