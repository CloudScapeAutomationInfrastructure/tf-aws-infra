# Define the AWS region
variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-2"
}

# Define the VPC CIDR block
variable "vpc_cidr_block" {
  description = "Base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Define the availability zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

# Define the AMI ID for EC2 instance
variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0b59e1727222f2247"  
}

# Define the instance type for EC2 instance
variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}

# Define the application port
variable "application_port" {
  description = "Port where the web application runs"
  default     = 5001
}

# Define the root volume size
variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  default     = 25
}

# Define the VPC name
variable "name" {
  description = "Name of the VPC"
  default     = "vpc2"
}

variable "keyname" {
  description = "Name of the key"
  default     = "csye6225"
}
