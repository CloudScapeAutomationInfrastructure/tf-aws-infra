# SNS Topic for User Creation
resource "aws_sns_topic" "user_created" {
  name = var.sns_topic_user_creation_name

  tags = {
    Environment = var.environment
    Project     = "UserCreation"
  }
}

# SNS Topic for User Verification
resource "aws_sns_topic" "user_verified" {
  name = var.sns_topic_user_verified_name

  tags = {
    Environment = var.environment
    Project     = "UserVerification"
  }
}

# Enable server-side encryption for User Creation SNS Topic
resource "aws_sns_topic" "user_created_encrypted" {
  name              = "${var.sns_topic_user_creation_name}-encrypted"
  kms_master_key_id = aws_kms_key.sns_encryption_key.arn

  tags = {
    Environment = var.environment
    Project     = "UserCreation"
  }
}

# Enable server-side encryption for User Verification SNS Topic
resource "aws_sns_topic" "user_verified_encrypted" {
  name              = "${var.sns_topic_user_verified_name}-encrypted"
  kms_master_key_id = aws_kms_key.sns_encryption_key.arn

  tags = {
    Environment = var.environment
    Project     = "UserVerification"
  }
}

# KMS Key for SNS Topic encryption
resource "aws_kms_key" "sns_encryption_key" {
  description         = "KMS key for SNS Topic encryption"
  enable_key_rotation = true

  tags = {
    Environment = var.environment
    Project     = "SNS-KMS"
  }
}

# KMS Key Alias
resource "aws_kms_alias" "sns_key_alias" {
  name          = "alias/sns-topic-key"
  target_key_id = aws_kms_key.sns_encryption_key.id
}

# SNS Topic Policy for User Creation: Allow Lambda to subscribe
resource "aws_sns_topic_policy" "user_created_policy" {
  arn = aws_sns_topic.user_created.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowLambdaSubscribe",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action   = "sns:Subscribe",
        Resource = aws_sns_topic.user_created.arn
      }
    ]
  })
}

# SNS Topic Policy for User Verification: Allow Lambda to subscribe
resource "aws_sns_topic_policy" "user_verified_policy" {
  arn = aws_sns_topic.user_verified.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowLambdaSubscribe",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action   = "sns:Subscribe",
        Resource = aws_sns_topic.user_verified.arn
      }
    ]
  })
}

# SNS Topic Subscription: Connect User Creation Topic to Lambda
resource "aws_sns_topic_subscription" "sns_to_lambda_user_created" {
  topic_arn = aws_sns_topic.user_created.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn

  depends_on = [aws_lambda_permission.allow_sns_invoke]
}

# SNS Topic Subscription: Connect User Verification Topic to Lambda
resource "aws_sns_topic_subscription" "sns_to_lambda_user_verified" {
  topic_arn = aws_sns_topic.user_verified.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn

  depends_on = [aws_lambda_permission.allow_sns_invoke]
}

# Outputs for SNS Topics
output "sns_topic_user_created_arn" {
  value       = aws_sns_topic.user_created.arn
  description = "SNS topic ARN for user creation"
}

output "sns_topic_user_verified_arn" {
  value       = aws_sns_topic.user_verified.arn
  description = "SNS topic ARN for user verification"
}
