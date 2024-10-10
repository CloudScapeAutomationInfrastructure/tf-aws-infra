variable "aws_region" {
  description = "Region where resources will be created"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "Base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for public and private subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "name" {
  type        = string
  description = "Name of the VPC"
  default     = "Vpc"
}


