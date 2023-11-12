resource "aws_s3_bucket" "ansible" {
  bucket = "mdekort.ansible"
}

resource "aws_s3_bucket_ownership_controls" "ansible" {
  bucket = aws_s3_bucket.ansible.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ansible" {
  depends_on = [aws_s3_bucket_ownership_controls.ansible]

  bucket = aws_s3_bucket.ansible.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "ansible" {
  bucket = aws_s3_bucket.ansible.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
