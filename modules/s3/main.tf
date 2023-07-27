resource "aws_s3_bucket" "s3_bucket_alb_access_logs" {
  bucket = var.bucket_name
  object_lock_enabled = false
  force_destroy = true
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.s3_bucket_alb_access_logs.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::127311923021:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.s3_bucket_alb_access_logs.bucket}/*"
        }
    ]
}
EOF
}