output "bucket" {
  value = aws_s3_bucket.node-js-s3.bucket
}
output "bucket_domain" {
  value = aws_s3_bucket.node-js-s3.bucket_domain_name
}
output "bucket_website_endpoint" {
  value = aws_s3_bucket.node-js-s3.website_endpoint
}