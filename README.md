# TechCorp AWS Infrastructure Deployment

This repository contains Terraform configuration files to deploy a highly available web application infrastructure on AWS for TechCorp.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Infrastructure Components](#infrastructure-components)
- [File Structure](#file-structure)
- [Deployment Instructions](#deployment-instructions)
- [Accessing the Infrastructure](#accessing-the-infrastructure)
- [Testing the Deployment](#testing-the-deployment)
- [Cleanup Instructions](#cleanup-instructions)
- [Troubleshooting](#troubleshooting)

## Architecture Overview

This infrastructure deployment creates a highly available, secure web application environment with:

- **Multi-AZ deployment** across two availability zones
- **Public and private subnets** for network isolation
- **Application Load Balancer** for traffic distribution
- **NAT Gateways** for secure outbound internet access from private subnets
- **Bastion host** for secure administrative access
- **Web servers** running Apache in private subnets
- **Database server** running PostgreSQL in a private subnet

## Prerequisites

Before you begin, ensure you have the following:

### Required Software

1. **Terraform** (version 1.0 or later)
   ```bash
   # Install Terraform
   # Visit: https://www.terraform.io/downloads
   terraform version
   ```

2. **AWS CLI** (configured with appropriate credentials)
   ```bash
   # Install AWS CLI
   # Visit: https://aws.amazon.com/cli/
   aws configure
   ```

3. **Git** (for cloning the repository)
   ```bash
   git --version
   ```

### AWS Requirements

1. **AWS Account** with appropriate permissions to create:
   - VPC and networking resources
   - EC2 instances
   - Load Balancers
   - Security Groups
   - Elastic IPs

2. **EC2 Key Pair** created in your target AWS region
   - Go to EC2 Console → Key Pairs → Create Key Pair
   - Download and save the `.pem` file securely
   - Note the key pair name for configuration

3. **Your Public IP Address**
   ```bash
   # Find your public IP
   curl ifconfig.me
   ```

## Infrastructure Components

### Networking

- **VPC**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.3.0/24, 10.0.4.0/24
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: 2 (one per AZ) for private subnet internet access

### Compute Resources

- **Bastion Host**: t3.micro in public subnet with Elastic IP
- **Web Servers**: 2x t3.micro in private subnets
- **Database Server**: 1x t3.small in private subnet

### Security

- **Bastion Security Group**: SSH from your IP only
- **Web Security Group**: HTTP/HTTPS from anywhere, SSH from bastion
- **Database Security Group**: PostgreSQL from web servers, SSH from bastion

### Load Balancing

- **Application Load Balancer**: Distributes traffic to web servers
- **Target Group**: Health checks on web servers
- **Listener**: HTTP on port 80

## File Structure

```
terraform-assessment/
├── main.tf                          # Main infrastructure definitions
├── variables.tf                     # Variable declarations
├── outputs.tf                       # Output definitions
├── terraform.tfvars.example         # Example variable values
├── user_data/
│   ├── web_server_setup.sh         # Apache installation script
│   └── db_server_setup.sh          # PostgreSQL installation script
├── README.md                        # This file
└── evidence/                        # Screenshots folder (create this)
```

## Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/month-one-assessment.git
cd month-one-assessment
```

### Step 2: Configure Variables

1. Copy the example terraform.tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```bash
   nano terraform.tfvars
   # or
   vim terraform.tfvars
   ```

3. Update the following required variables:
   ```hcl
   key_pair_name = "your-actual-key-pair-name"
   my_ip         = "YOUR.IP.ADDRESS/32"  # e.g., "203.0.113.25/32"
   ssh_password  = "YourSecurePassword123!"
   ```

### Step 3: Initialize Terraform

```bash
terraform init
```

This command:
- Downloads required provider plugins
- Initializes the backend
- Prepares the working directory

### Step 4: Review the Deployment Plan

```bash
terraform plan
```

This command shows:
- All resources that will be created
- Any changes to existing resources
- Resource dependencies

**Take a screenshot of the plan output for submission!**

### Step 5: Deploy the Infrastructure

```bash
terraform apply
```

- Review the plan one more time
- Type `yes` when prompted to confirm
- Wait for deployment to complete (typically 5-10 minutes)

**Take a screenshot of the successful apply output for submission!**

### Step 6: Save the Outputs

```bash
terraform output
```

Save important outputs:
- Load Balancer DNS name
- Bastion host public IP
- Web server private IPs
- Database server private IP

## 🔐 Accessing the Infrastructure

### Access the Web Application

The web application is accessible via the Application Load Balancer:

```bash
# Get the Load Balancer URL
terraform output load_balancer_url

# Or directly
terraform output load_balancer_dns_name
```

Open the URL in your web browser to see the web application.

### Access the Bastion Host

#### Option 1: Using SSH Key

```bash
ssh -i /path/to/your-key.pem ec2-user@<BASTION_PUBLIC_IP>
```

#### Option 2: Using Password

```bash
ssh admin@<BASTION_PUBLIC_IP>
# Password: TechCorp2024!Secure (or your configured password)
```

### Access Web Servers (via Bastion)

First, connect to the bastion host, then:

```bash
# Connect to Web Server 1
ssh ec2-user@<WEB_SERVER_1_PRIVATE_IP>

# Or using password
ssh admin@<WEB_SERVER_1_PRIVATE_IP>
# Password: TechCorp2024!Secure
```

### Access Database Server (via Bastion)

First, connect to the bastion host, then:

```bash
# SSH to database server
ssh ec2-user@<DATABASE_SERVER_PRIVATE_IP>

# Once connected, access PostgreSQL
sudo -u postgres psql -d techcorp_db

# Or as techcorp_user
psql -h localhost -U techcorp_user -d techcorp_db
# Password: TechCorp2024!DB
```

## Testing the Deployment

### 1. Test Web Application Access

```bash
# Get the Load Balancer URL
LB_URL=$(terraform output -raw load_balancer_dns_name)

# Test HTTP access
curl http://$LB_URL

# Test multiple times to see load balancing
for i in {1..10}; do
  curl -s http://$LB_URL | grep "Instance ID"
done
```

**Take a screenshot of the web page in your browser showing the instance ID!**

### 2. Test Bastion Access

```bash
# SSH to bastion
ssh -i your-key.pem ec2-user@$(terraform output -raw bastion_public_ip)
```

**Take a screenshot showing successful SSH connection to bastion!**

### 3. Test Web Server Access via Bastion

From the bastion host:

```bash
# Get web server IPs
WEB_1_IP=$(terraform output -raw web_server_1_private_ip)
WEB_2_IP=$(terraform output -raw web_server_2_private_ip)

# SSH to web servers
ssh admin@$WEB_1_IP
ssh admin@$WEB_2_IP
```

**Take screenshots showing SSH access to both web servers!**

### 4. Test Database Server Access and PostgreSQL

From the bastion host:

```bash
# SSH to database server
DB_IP=$(terraform output -raw database_server_private_ip)
ssh admin@$DB_IP

# Once on the database server, test PostgreSQL
sudo -u postgres psql -d techcorp_db -c "SELECT * FROM app_info;"
```

**Take screenshots showing:**
- SSH access to database server
- Successful PostgreSQL connection
- Query results from the database

### 5. Verify AWS Console

Login to AWS Console and verify:
- VPC and subnets are created
- EC2 instances are running
- Load Balancer is active and healthy
- Security groups are configured correctly

**Take screenshots of AWS Console showing the created resources!**

## Cleanup Instructions

To avoid ongoing AWS charges, destroy the infrastructure when done:

### Step 1: Review Resources to be Destroyed

```bash
terraform plan -destroy
```

### Step 2: Destroy the Infrastructure

```bash
terraform destroy
```

- Review the resources that will be destroyed
- Type `yes` when prompted to confirm
- Wait for destruction to complete (typically 5-10 minutes)

### Step 3: Verify Cleanup

1. Check AWS Console to ensure all resources are deleted
2. Verify no Elastic IPs are still allocated
3. Check for any remaining NAT Gateways

### Manual Cleanup (if needed)

If some resources fail to delete:

```bash
# List any remaining resources
aws ec2 describe-instances --filters "Name=tag:Name,Values=techcorp-*"
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=techcorp-vpc"

# Manually delete stuck resources via AWS Console
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: Terraform Init Fails

**Error**: `Failed to query available provider packages`

**Solution**:
```bash
# Clear Terraform cache
rm -rf .terraform
rm .terraform.lock.hcl

# Re-initialize
terraform init
```

#### Issue: Key Pair Not Found

**Error**: `InvalidKeyPair.NotFound`

**Solution**:
- Verify the key pair exists in your AWS region
- Check the key pair name in `terraform.tfvars`
- Create a new key pair if needed:
  ```bash
  aws ec2 create-key-pair --key-name techcorp-key --query 'KeyMaterial' --output text > techcorp-key.pem
  chmod 400 techcorp-key.pem
  ```

#### Issue: Cannot Access Bastion Host

**Error**: `Connection timed out`

**Solution**:
- Verify your IP address in `terraform.tfvars`
- Check security group rules in AWS Console
- Ensure Elastic IP is associated with bastion
- Verify the bastion instance is running

#### Issue: Load Balancer Shows Unhealthy Targets

**Error**: Targets show as unhealthy in Target Group

**Solution**:
```bash
# SSH to a web server and check Apache status
sudo systemctl status httpd

# Check Apache logs
sudo tail -f /var/log/httpd/error_log

# Restart Apache if needed
sudo systemctl restart httpd
```

#### Issue: Cannot Connect to Database

**Error**: `Connection refused` when connecting to PostgreSQL

**Solution**:
```bash
# SSH to database server
# Check PostgreSQL status
sudo systemctl status postgresql

# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-*.log

# Restart PostgreSQL if needed
sudo systemctl restart postgresql

# Verify PostgreSQL is listening
sudo netstat -tlnp | grep 5432
```

#### Issue: User Data Scripts Didn't Run

**Solution**:
```bash
# SSH to the instance
# Check user data execution logs
sudo cat /var/log/cloud-init-output.log
sudo cat /var/log/user-data.log

# Manually run the setup script if needed
sudo bash /var/lib/cloud/instance/user-data.txt
```

### Getting Help

If you encounter issues not covered here:

1. Check Terraform documentation: https://www.terraform.io/docs
2. Review AWS service documentation
3. Check CloudWatch logs for instance errors
4. Review VPC Flow Logs for network issues

## Cost Estimation

Approximate monthly costs (us-east-1 region):

- EC2 Instances: ~$45/month
  - 3x t3.micro ($0.0104/hour each)
  - 1x t3.small ($0.0208/hour)
- NAT Gateways: ~$65/month
  - 2x NAT Gateway ($0.045/hour each)
- Application Load Balancer: ~$16/month
- Data Transfer: Variable (depends on usage)
- Elastic IPs: ~$3/month (when not associated)

**Total: ~$130-150/month**

**Note**: Costs vary by region and actual usage. Always check AWS Pricing Calculator for accurate estimates.

## Submission Checklist

Ensure you have:

- [ ] All Terraform configuration files
- [ ] User data scripts
- [ ] README.md with deployment instructions
- [ ] Screenshot: Terraform plan output
- [ ] Screenshot: Terraform apply completion
- [ ] Screenshot: AWS Console showing VPC and subnets
- [ ] Screenshot: AWS Console showing EC2 instances
- [ ] Screenshot: AWS Console showing Load Balancer
- [ ] Screenshot: Web application accessible via ALB (showing instance ID)
- [ ] Screenshot: SSH access to bastion host
- [ ] Screenshot: SSH access to web server via bastion
- [ ] Screenshot: SSH access to database server via bastion
- [ ] Screenshot: PostgreSQL connection and query results
- [ ] terraform.tfstate file (ensure no sensitive data)

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Load Balancer Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)

## Author
- Ifeanyi Franklin Ike
