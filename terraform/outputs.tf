output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.task_tracker.public_ip
}

output "ec2_ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i project.pem ubuntu@${aws_instance.task_tracker.public_ip}"
}

output "s3_bucket_name" {
  description = "Name of S3 bucket for logs"
  value       = var.create_s3_bucket ? aws_s3_bucket.logs[0].bucket : "No bucket created"
}

output "api_url_port_80" {
  description = "URL to access the API on port 80"
  value       = "http://${aws_instance.task_tracker.public_ip}"
}

output "api_url_port_3000" {
  description = "URL to access the API on port 3000"
  value       = "http://${aws_instance.task_tracker.public_ip}:3000"
}
