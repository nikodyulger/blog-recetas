locals {
  s3_origin_id = "blog_bucket_origin_${aws_s3_bucket.blog_bucket.id}"
}

resource "aws_cloudfront_origin_access_identity" "blog_oai_s3_cdn" {
  comment = "OAI Cloudfront para acceder al blog_bucket"
}

resource "aws_cloudfront_distribution" "blog_distribution" {

  origin {
    domain_name = aws_s3_bucket.blog_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.blog_oai_s3_cdn.cloudfront_access_identity_path
    }
  }

  aliases = [
    var.blog_domain_name
  ]
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  comment             = "CDN para el blog_bucket"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.blog_ssl_certificate.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}