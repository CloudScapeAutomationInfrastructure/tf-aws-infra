resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%!" # Avoid '/', '@', '"', and space
}

# Secrets Manager for database credentials
resource "aws_secretsmanager_secret" "database_credentials" {
  name       = "database-credentials"
  kms_key_id = aws_kms_key.secrets_kms_key.arn

  tags = {
    Name        = "Database Credentials Secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "database_credentials_version" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    password = random_password.db_password.result
  })
}

# Secrets Manager for email service credentials
resource "aws_secretsmanager_secret" "email_service_credentials" {
  name       = "email-service-credentials"
  kms_key_id = aws_kms_key.secrets_kms_key.arn

  tags = {
    Name        = "Email Service Credentials Secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "email_service_credentials_version" {
  secret_id = aws_secretsmanager_secret.email_service_credentials.id
  secret_string = jsonencode({
    SENDGRID_API_KEY = var.sendgrid_api_key,
    FROM_EMAIL       = var.from_email,
    REPLY_TO_EMAIL   = var.reply_to_email
  })
}

# Outputs for debugging and referencing 
output "database_credentials_name" {
  value       = aws_secretsmanager_secret.database_credentials.name
  description = "Name of the database credentials secret"
}

output "email_service_credentials_name" {
  value       = aws_secretsmanager_secret.email_service_credentials.name
  description = "Name of the email service credentials secret"
}
