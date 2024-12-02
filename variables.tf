# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-2"
}

# Project Name
variable "project" {
  description = "Project name for tagging and resource identification"
  default     = "WebAppProject"
}

# VPC Configuration
variable "vpc_cidr_block" {
  description = "Base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

# EC2 Configuration
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

variable "root_volume_type" {
  description = "EBS volume type for the root volume"
  default     = "gp2"
}

# Application and Environment Configuration
variable "name" {
  description = "Name of the VPC and other associated resources"
  default     = "vpc2"
}

variable "environment" {
  description = "Environment for resources (e.g., dev, prod, test)"
  default     = "dev"
}

variable "keyname" {
  description = "Name of the key pair for EC2 instances"
  default     = "csye6225"
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  default     = "image-upload-s3-bucket"
}

variable "s3_lifecycle_days" {
  description = "Number of days before transitioning objects to STANDARD_IA"
  default     = 30
}

# SNS Configuration
variable "sns_topic_name" {
  description = "SNS topic name"
  default     = "user-created-topic"
}

variable "sns_topic_user_creation_name" {
  description = "SNS topic name for user creation"
  default     = "user-created-topic"
}

variable "sns_topic_user_verified_name" {
  description = "SNS topic name for user verification"
  default     = "user-verified-topic"
}

# Lambda Configuration
variable "lambda_function_name" {
  description = "Lambda function name"
  default     = "email-verification-function"
}

variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
  default     = "python3.8"
}

variable "lambda_package_path" {
  description = "Path to the deployment package for the Lambda function"
  default     = "C:/Users/sri15/Downloads/lambdacode_assig09/lambda_function.zip"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  default     = 256
}

# RDS Configuration
variable "rds_host" {
  description = "RDS database host (optional override)"
  type        = string
  default     = null
}

variable "rds_user" {
  description = "RDS database username"
}

variable "rds_password" {
  description = "RDS database password"
}

variable "rds_name" {
  description = "RDS database name"
}

# Email Configuration
variable "domain_name" {
  description = "Domain name for verification links"
  default     = "demo.awsclouddomainname.me"
}

variable "from_email" {
  description = "Email address used for sending verification emails"
  default     = "nag.sr@northeastern.edu"
}

variable "reply_to_email" {
  description = "Reply-to email address for emails sent"
  default     = "sri15nag@gmail.com"
}

# IAM Configuration
variable "iam_role_name" {
  description = "Name of the IAM role for the Lambda function"
  default     = "lambda-execution-role"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy for the Lambda function"
  default     = "lambda-execution-policy"
}

# Auto Scaling Group Configuration
variable "asg_min_size" {
  description = "Minimum size of the auto-scaling group"
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size of the auto-scaling group"
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the auto-scaling group"
  default     = 3
}

# CloudWatch Configuration
variable "log_group_name" {
  description = "Log group name for CloudWatch"
  default     = "serverless-app-log-group"
}

# Encryption Configuration
variable "enable_kms_encryption" {
  description = "Enable KMS encryption for sensitive resources (e.g., SNS, S3)"
  type        = bool
  default     = true
}

variable "kms_key_aliases" {
  description = "List of KMS key aliases for various resources"
  type        = map(string)
  default = {
    ec2_kms_key        = "alias/ec2-kms-key"
    rds_kms_key        = "alias/rds-kms-key"
    s3_kms_key         = "alias/s3-kms-key"
    secrets_kms_key    = "alias/secrets-kms-key"
    sensitive_data_key = "alias/sensitive-data-kms-key"
  }
}

# SendGrid Configuration
variable "sendgrid_api_key" {
  description = "SendGrid API key for sending emails"
  type        = string
}

# Additional Outputs
variable "output_sns_topic_arn" {
  description = "Enable or disable output of SNS topic ARN"
  type        = bool
  default     = true
}

# Certificate Configuration
variable "demo_certificate_arn" {
  description = "ARN of the ACM certificate for the demo environment"
  type        = string
  default     = "arn:aws:acm:us-east-2:311141531170:certificate/4761ced3-18ed-4606-8a1b-168f364bbae2"
}

variable "dev_certificate_arn" {
  description = "ARN of the ACM certificate for the dev environment"
  type        = string
  default     = "arn:aws:acm:us-east-2:122610501029:certificate/6f50c425-4a73-4c1a-8dd5-617c78988338"

}
