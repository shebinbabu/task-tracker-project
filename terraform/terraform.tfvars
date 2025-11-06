# ⚠️ CHANGE THIS: Replace with your AWS region
aws_region = "ap-south-1"

# ⚠️ CHANGE THIS: EC2 instance type (t3.micro is free tier eligible)
instance_type = "t3.micro"

# ⚠️ CHANGE THIS: Replace with your AWS EC2 key pair name
# Go to AWS Console → EC2 → Key Pairs to see your key pair name
key_name = "project"

# ⚠️ CHANGE THIS: Replace with your public IP address for better security
# Find your IP: curl ifconfig.me
# Format: "YOUR_IP/32" (e.g., "203.0.113.45/32")
# Or use "0.0.0.0/0" to allow from anywhere (less secure)
my_ip = "0.0.0.0/0"

# ✅ Leave as-is: Create S3 bucket for logs
create_s3_bucket = true