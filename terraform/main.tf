# Find latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group allowing ports 80/3000 as per requirement
resource "aws_security_group" "task_tracker_sg" {
  name        = "task-tracker-sg"
  description = "Security group for Task Tracker API - allows port 80/3000"

  # Port 80 - Standard HTTP
  ingress {
    description = "HTTP port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 3000 - Alternative HTTP port
  ingress {
    description = "HTTP port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 22 - SSH for deployment
  ingress {
    description = "SSH for deployment"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task-tracker-sg"
  }
}

# EC2 instance (Ubuntu 22+)
resource "aws_instance" "task_tracker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.task_tracker_sg.id]

  # User data to install Docker on first boot
  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "task-tracker-ec2"
  }
}

# Random string for unique S3 bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for logs/artifacts (optional)
resource "aws_s3_bucket" "logs" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = "task-tracker-logs-${random_string.bucket_suffix.result}"

  tags = {
    Name = "task-tracker-logs"
  }
}
