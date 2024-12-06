# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2ExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for EC2 Role
resource "aws_iam_policy" "ec2_policy" {
  name = "EC2ExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::image-upload-s3-bucket-${random_id.s3_bucket.hex}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.user_created.arn
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:RestoreSecret",
          "secretsmanager:GetRandomPassword"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:CreateKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyPair",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey",
          "kms:ListKeys",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:UpdateAlias",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:ListAliases",
          "kms:EnableKey",
          "kms:DisableKey",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for S3 and KMS Access
resource "aws_iam_policy" "s3_and_kms_access" {
  name = "S3AndKMSAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.image_storage.id}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "${aws_kms_key.s3_kms_key.arn}"
      }
    ]
  })
}

# Route 53 Policy for EC2 Role
resource "aws_iam_policy" "route53_policy" {
  name = "Route53AccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "arn:aws:route53:::hostedzone/Z02358762FHWIMLLNZDGB"
      }
    ]
  })
}

# Attach Policies to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "route53_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.route53_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_s3_and_kms_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_and_kms_access.arn
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda Role
resource "aws_iam_policy" "lambda_execution_policy" {
  name = "LambdaExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ],
        Resource = aws_sns_topic.user_created.arn
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}
