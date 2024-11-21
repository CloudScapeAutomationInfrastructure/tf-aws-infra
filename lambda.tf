# Lambda Function for User Notification
resource "aws_lambda_function" "email_verification" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = "C:/Users/sri15/Downloads/lambdacode/lambda_function.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN    = aws_sns_topic.user_created.arn
      DOMAIN_NAME      = var.domain_name
      FROM_EMAIL       = var.from_email
      SENDGRID_API_KEY = var.sendgrid_api_key
    }
  }

  timeout     = 30
  memory_size = 256
  description = "Lambda function to send email verification and track in RDS."

  tags = {
    Environment = "Development"
    Project     = "EmailVerification"
  }
}

# Lambda Permission: Allow SNS to invoke the Lambda function
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_created.arn
}
