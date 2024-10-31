resource "random_id" "s3_bucket" {
  byte_length = 2
}


resource "aws_s3_bucket" "image_storage" {
  bucket        = "image-upload-s3-bucket-unique123"
  force_destroy = true

  tags = {
    Name = "image-upload-s3-bucket-unique123"
  }
}



resource "aws_s3_bucket_lifecycle_configuration" "image_storage_lifecycle" {
  bucket = aws_s3_bucket.image_storage.id

  rule {
    id     = "TransitionToIA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Separate encryption configuration for S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "image_storage_encryption" {
  bucket = aws_s3_bucket.image_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
