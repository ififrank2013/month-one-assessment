#!/bin/bash
# Web Server Setup Script for TechCorp
# This script installs and configures Apache web server on Amazon Linux 2

# Update system packages
yum update -y

# Install Apache web server
yum install -y httpd

# Enable password authentication for SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Create admin user for SSH access
useradd -m -s /bin/bash admin
echo "admin:TechCorp2024!Secure" | chpasswd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a custom index.html page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechCorp Web Server</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: #333;
        }
        .container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 600px;
            text-align: center;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .subtitle {
            color: #764ba2;
            font-size: 1.2em;
            margin-bottom: 30px;
        }
        .info-box {
            background: #f7f7f7;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
        }
        .info-box h3 {
            margin-top: 0;
            color: #667eea;
        }
        .info-item {
            margin: 10px 0;
            padding: 8px;
            background: white;
            border-radius: 5px;
        }
        .label {
            font-weight: bold;
            color: #764ba2;
        }
        .value {
            color: #333;
            font-family: 'Courier New', monospace;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            background: #4caf50;
            color: white;
            border-radius: 20px;
            font-size: 0.9em;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 TechCorp</h1>
        <p class="subtitle">Web Application Infrastructure</p>
        
        <div class="info-box">
            <h3>Server Information</h3>
            <div class="info-item">
                <span class="label">Instance ID:</span>
                <span class="value">$INSTANCE_ID</span>
            </div>
            <div class="info-item">
                <span class="label">Availability Zone:</span>
                <span class="value">$AVAILABILITY_ZONE</span>
            </div>
            <div class="info-item">
                <span class="label">Private IP:</span>
                <span class="value">$PRIVATE_IP</span>
            </div>
        </div>
        
        <p>This server is running behind an Application Load Balancer</p>
        <div class="status">✓ Server Online</div>
    </div>
</body>
</html>
EOF

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Configure firewall (if needed)
systemctl start firewalld 2>/dev/null || true
firewall-cmd --permanent --add-service=http 2>/dev/null || true
firewall-cmd --permanent --add-service=https 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true

# Create a health check endpoint
echo "OK" > /var/www/html/health.html

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Log completion
echo "Web server setup completed successfully at $(date)" >> /var/log/user-data.log