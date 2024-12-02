# Lambda Function for User Notification
resource "aws_lambda_function" "email_verification" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = var.lambda_package_path

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.user_created.arn
      DOMAIN_NAME   = var.domain_name
      FROM_EMAIL    = var.from_email
      SECRETS_ARN   = aws_secretsmanager_secret.email_service_credentials.arn
    }
  }

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  description = "Lambda function to send email verification and track in RDS."

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Lambda Permission to Allow SNS to Invoke the Lambda Function
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_created.arn
}
