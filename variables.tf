
variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-2"
}


variable "vpc_cidr_block" {
  description = "Base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}


variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}


variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0b59e1727222f2247"
}


variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}


variable "application_port" {
  description = "Port where the web application runs"
  default     = 5000
}


variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  default     = 25
}


variable "name" {
  description = "Name of the VPC"
  default     = "vpc2"
}


variable "keyname" {
  description = "Name of the key"
  default     = "csye6225"
}
