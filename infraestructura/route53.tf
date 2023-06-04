resource "aws_acm_certificate" "blog_ssl_certificate" {

  domain_name       = var.blog_domain_name
  provider          = aws.us-east-1
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

data "aws_route53_zone" "blog_hosted_zone" {
  name         = var.blog_domain_name
  private_zone = false
}

resource "aws_route53_record" "blog_cert_val_record" {
  for_each = {
    for dvo in aws_acm_certificate.blog_ssl_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.blog_hosted_zone.zone_id

}

resource "aws_route53_record" "blog_distribution_domain" {
  zone_id = data.aws_route53_zone.blog_hosted_zone.zone_id
  name    = var.blog_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.blog_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.blog_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "blog_ssl_cert_validation" {
  certificate_arn         = aws_acm_certificate.blog_ssl_certificate.arn
  provider                = aws.us-east-1
  validation_record_fqdns = [for record in aws_route53_record.blog_cert_val_record : record.fqdn]
}