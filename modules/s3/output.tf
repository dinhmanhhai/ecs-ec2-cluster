output "bucket_name" {
  value = aws_s3_bucket.s3_bucket_alb_access_logs.bucket
}
output "bucket_domain" {
  value = aws_s3_bucket.s3_bucket_alb_access_logs.bucket_domain_name
}
