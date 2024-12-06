data "aws_caller_identity" "current" {}

# KMS Key for EC2
resource "aws_kms_key" "ec2_kms_key" {
  description         = "KMS key for encrypting EC2 volumes"
  enable_key_rotation = true
  tags = {
    Name        = "ec2-kms-key"
    Purpose     = "Encrypt EC2 Volumes"
    Environment = var.environment
  }
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-consolepolicy-3"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 service to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Auto Scaling service-linked role to use the KMS key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
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
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowUseOfKey",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_role.name}"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*"
      }
    ]
  })
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

output "s3_kms_key_arn" {
  value       = aws_kms_key.s3_kms_key.arn
  description = "The ARN of the KMS key for S3 encryption"
}


