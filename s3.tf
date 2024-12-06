# Generate Random ID for Unique Bucket Name
resource "random_id" "s3_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "image_storage" {
  bucket        = "image-upload-s3-bucket-${random_id.s3_bucket.hex}"
  force_destroy = true

  tags = {
    Name        = "image-upload-s3-bucket-${random_id.s3_bucket.hex}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "image_storage_lifecycle" {
  bucket = aws_s3_bucket.image_storage.id

  rule {
    id     = "TransitionToIA"
    status = "Enabled"

    transition {
      days          = var.s3_lifecycle_days
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_versioning" "image_storage_versioning" {
  bucket = aws_s3_bucket.image_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption with KMS Key
resource "aws_s3_bucket_server_side_encryption_configuration" "image_storage_encryption" {
  bucket = aws_s3_bucket.image_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
    }
  }
}

# Updated S3 Bucket Policy for Access Control
resource "aws_s3_bucket_policy" "image_storage_policy" {
  bucket = aws_s3_bucket.image_storage.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyUnsecureTransport",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.image_storage.arn}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid       = "DenyUnencryptedUploads",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.image_storage.arn}/*",
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      }
    ]
  })
}
