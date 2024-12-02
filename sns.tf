# SNS Topic for User Creation
resource "aws_sns_topic" "user_created" {
  name = var.sns_topic_user_creation_name

  tags = {
    Environment = var.environment
    Project     = "UserCreation"
  }
}

# SNS Topic Policy for User Creation: Allow Lambda to subscribe
resource "aws_sns_topic_policy" "user_created_policy" {
  arn = aws_sns_topic.user_created.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowLambdaSubscribe",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sns:Subscribe",
        Resource  = aws_sns_topic.user_created.arn
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

# Outputs for SNS Topics
output "sns_topic_user_created_arn" {
  value       = aws_sns_topic.user_created.arn
  description = "SNS topic ARN for user creation"
}
