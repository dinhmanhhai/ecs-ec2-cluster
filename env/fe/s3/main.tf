locals {
  prefix_name = "${var.project}-${var.environment}"
}

resource "aws_s3_bucket" "node-js-s3" {
  bucket = "${local.prefix_name}-node-js"
  object_lock_enabled = false
  force_destroy = true
}

/* Message: The object was stored using a form of Server Side Encryption. The correct parameters must be provided to retrieve the object. */
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.node-js-s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.node-js-s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.node-js-s3.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.node-js-s3.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_website_configuration" "example-config" {
  bucket = aws_s3_bucket.node-js-s3.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "example-policy" {
  bucket = aws_s3_bucket.node-js-s3.id
  policy = data.template_file.ecr_policy.rendered
}

data "template_file" "ecr_policy" {
  template = file("${path.module}/templates/s3-policy.json")

  vars = {
    bucket = aws_s3_bucket.node-js-s3.bucket
  }
}

/* NOTE: Logging (đang lỗi quyền :v tính sau) */
#resource "aws_s3_bucket_acl" "log_bucket_acl" {
#  bucket = var.bucket_name
#  acl    = "log-delivery-write"
#}
#
#resource "aws_s3_bucket_logging" "example" {
#  bucket = aws_s3_bucket.node-js-s3.bucket
#
#  target_bucket = var.bucket_name
#  target_prefix = "log/${local.prefix_name}/"
#}