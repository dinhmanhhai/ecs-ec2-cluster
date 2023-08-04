locals {
  prefix_name = "${var.project}-${var.environment}"
}

data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}

#module "cdn" {
#  source = "../../modules/cdn"
#
#  aliases = ["cdn.example.com"]
#
#  comment             = "My awesome CloudFront"
#  enabled             = true
#  is_ipv6_enabled     = true
#  price_class         = "PriceClass_All"
#  retain_on_delete    = false
#  wait_for_deployment = false
#
#  create_origin_access_identity = true
#  origin_access_identities = {
#    s3_bucket_one = data.terraform_remote_state.fe_s3.outputs.bucket
#  }
#
##  logging_config = {
##    bucket = "logs-my-cdn.s3.amazonaws.com"
##  }
#
#  origin = {
##    something = {
##      domain_name = "something.example.com"
##      custom_origin_config = {
##        http_port              = 80
##        https_port             = 443
##        origin_protocol_policy = "match-viewer"
##        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
##      }
##    }
#
#    s3_one = {
#      domain_name = data.terraform_remote_state.fe_s3.outputs.http://demo-dev-node-js.s3-website-us-east-1.amazonaws.com
#      s3_origin_config = {
#        origin_access_identity = "s3_bucket_one"
#      }
#    }
#  }
#
##  default_cache_behavior = {
##    target_origin_id           = "something"
##    viewer_protocol_policy     = "allow-all"
##
##    allowed_methods = ["GET", "HEAD", "OPTIONS"]
##    cached_methods  = ["GET", "HEAD"]
##    compress        = true
##    query_string    = true
##  }
#
##  ordered_cache_behavior = [
##    {
##      path_pattern           = "/*"
##      target_origin_id       = "s3_one"
##      viewer_protocol_policy = "redirect-to-https"
##
##      allowed_methods = ["GET", "HEAD", "OPTIONS"]
##      cached_methods  = ["GET", "HEAD"]
##      compress        = true
##      query_string    = true
##    }
##  ]
#
##  viewer_certificate = {
##    acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
##    ssl_support_method  = "sni-only"
##  }
#}

resource "aws_cloudfront_distribution" "node-js-cdn" {

  enabled         = var.create_cdn
  is_ipv6_enabled = true

  origin {
    domain_name = data.terraform_remote_state.fe_s3.outputs.bucket_website_endpoint
    origin_id   = data.terraform_remote_state.fe_s3.outputs.bucket

    origin_shield {
      enabled              = false
      origin_shield_region = var.aws_region
    }
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
    connection_attempts = 3
    connection_timeout  = 10
    #    custom_header {
    #      name  = null
    #      value = null
    #    }
  }

#  logging_config {
#    bucket = "${var.cache_bucket_name}/"
#  }

  #  ordered_cache_behavior {
  #
  #    path_pattern           = ""
  #    target_origin_id       = ""
  #    viewer_protocol_policy = ""
  #    allowed_methods {}
  #    cached_methods {}
  #  }

  default_cache_behavior {
    target_origin_id       = data.terraform_remote_state.fe_s3.outputs.bucket
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-optimized.id

#    forwarded_values {
#      query_string = true
#      cookies {
#        forward           = "none"
#        whitelisted_names = []
#      }
#    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    #    acm_certificate_arn            = null
    #    iam_certificate_id             = null
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }
}
