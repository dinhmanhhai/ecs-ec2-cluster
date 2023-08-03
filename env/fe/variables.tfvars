#Global
environment = "dev"
aws_profile = "default"
aws_region  = "us-east-1"
project     = "demo"

#S3
bucket_name = "haidm-infra-remote-state"
cache_bucket_name = "all-cache-and-log"
block_public_acls = false
block_public_policy = false
ignore_public_acls = false
restrict_public_buckets = false
insecure_ssl = false
badge_enabled = false
extract_when_deploy = true
bucket_key_enabled = true

#Branch match env
branch_match = {
  dev: "dev",
  stg: "stg",
  prod: "master"
}
build_timeout = "5"

#CDN
create_cdn = true