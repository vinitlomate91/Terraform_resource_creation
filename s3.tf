
resource "aws_s3_bucket" "s3_state" {
     bucket = "terraforms3328062026"

     tags = {
        Name = "terraforms3328062026"
     }
}

resource "aws_s3_bucket" "s3_state1" {
     bucket = "testing28062026"

     tags = {
        Name = "testing28062026"
     }
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
     bucket = aws_s3_bucket.s3_state.id

     versioning_configuration {
        status = "Enabled"
     }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.s3_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}