#!/bin/bash
# Database Server Setup Script for TechCorp
# This script installs and configures PostgreSQL on Amazon Linux 2

# Update system packages
yum update -y

# Enable password authentication for SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Create admin user for SSH access
useradd -m -s /bin/bash admin
echo "admin:TechCorp2024!Secure" | chpasswd

# Install PostgreSQL
amazon-linux-extras enable postgresql14
yum install -y postgresql postgresql-server postgresql-contrib

# Initialize PostgreSQL database
postgresql-setup initdb

# Configure PostgreSQL to accept connections
# Backup original configuration
cp /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.backup
cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.backup

# Configure PostgreSQL to listen on all interfaces
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf

# Allow connections from VPC CIDR range
cat >> /var/lib/pgsql/data/pg_hba.conf <<EOF

# Allow connections from VPC
host    all             all             10.0.0.0/16             md5
EOF

# Start and enable PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Wait for PostgreSQL to be ready
sleep 5

# Create database and user
sudo -u postgres psql <<EOF
-- Create database
CREATE DATABASE techcorp_db;

-- Create user with password
CREATE USER techcorp_user WITH PASSWORD 'TechCorp2024!DB';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE techcorp_db TO techcorp_user;

-- Create a sample table
\c techcorp_db

CREATE TABLE app_info (
    id SERIAL PRIMARY KEY,
    app_name VARCHAR(100),
    version VARCHAR(20),
    deployed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_info (app_name, version) VALUES ('TechCorp Web Application', '1.0.0');

-- Grant table privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO techcorp_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO techcorp_user;

-- Display success message
SELECT 'Database setup completed successfully!' AS status;
EOF

# Configure firewall (if needed)
systemctl start firewalld 2>/dev/null || true
firewall-cmd --permanent --add-service=postgresql 2>/dev/null || true
firewall-cmd --permanent --add-port=5432/tcp 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true

# Create a script to test database connection
cat > /home/ec2-user/test_db.sh <<'EOF'
#!/bin/bash
echo "Testing PostgreSQL connection..."
psql -h localhost -U postgres -d techcorp_db -c "SELECT * FROM app_info;"
EOF

chmod +x /home/ec2-user/test_db.sh
chown ec2-user:ec2-user /home/ec2-user/test_db.sh

# Create database info file
cat > /home/ec2-user/db_info.txt <<EOF
===========================================
TechCorp Database Server Information
===========================================

Database: techcorp_db
User: techcorp_user
Password: TechCorp2024!DB
Port: 5432

Postgres Superuser: postgres (use 'sudo -u postgres psql' for admin access)

To connect to the database:
  psql -h localhost -U techcorp_user -d techcorp_db

To connect as postgres admin:
  sudo -u postgres psql

To test the database:
  ./test_db.sh

===========================================
Database setup completed at: $(date)
===========================================
EOF

chown ec2-user:ec2-user /home/ec2-user/db_info.txt

# Log completion
echo "Database server setup completed successfully at $(date)" >> /var/log/user-data.log

# Display status
systemctl status postgresql --no-pager >> /var/log/user-data.log