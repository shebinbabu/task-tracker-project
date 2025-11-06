variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of existing AWS EC2 key pair for SSH access"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access (CIDR format)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "create_s3_bucket" {
  description = "Whether to create S3 bucket for logs"
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "Name of AWS profile"
  type        = string
  default     = "myaws"
}
