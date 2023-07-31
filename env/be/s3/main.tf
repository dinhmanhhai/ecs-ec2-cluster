resource "aws_s3_bucket" "s3-backend" {
  bucket = var.bucket_name
  object_lock_enabled = false
  force_destroy = true
}