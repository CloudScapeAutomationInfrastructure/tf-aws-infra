# KMS Key for EC2
resource "aws_kms_key" "ec2_kms_key" {
  description         = "KMS key for encrypting EC2 volumes"
  enable_key_rotation = true
  tags = {
    Name        = "ec2-kms-key"
    Purpose     = "Encrypt EC2 Volumes"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "ec2_kms_key_alias" {
  name          = "alias/ec2-kms-key"
  target_key_id = aws_kms_key.ec2_kms_key.key_id
}

# KMS Key for RDS
resource "aws_kms_key" "rds_kms_key" {
  description         = "KMS key for encrypting RDS instances"
  enable_key_rotation = true
  tags = {
    Name        = "rds-kms-key"
    Purpose     = "Encrypt RDS Instances"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "rds_kms_key_alias" {
  name          = "alias/rds-kms-key"
  target_key_id = aws_kms_key.rds_kms_key.key_id
}

# KMS Key for S3
resource "aws_kms_key" "s3_kms_key" {
  description         = "KMS key for encrypting S3 buckets"
  enable_key_rotation = true
  tags = {
    Name        = "s3-kms-key"
    Purpose     = "Encrypt S3 Buckets"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "s3_kms_key_alias" {
  name          = "alias/s3-kms-key"
  target_key_id = aws_kms_key.s3_kms_key.key_id
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets_kms_key" {
  description         = "KMS key for encrypting Secrets Manager"
  enable_key_rotation = true
  tags = {
    Name        = "secrets-kms-key"
    Purpose     = "Encrypt Secrets Manager"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "secrets_kms_key_alias" {
  name          = "alias/secrets-kms-key"
  target_key_id = aws_kms_key.secrets_kms_key.key_id
}
