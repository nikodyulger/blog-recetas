output "route53_domain" {
  value = "${aws_route53_record.blog_distribution_domain.fqdn}"
}

output "cdn_domain" {
  value = "${aws_cloudfront_distribution.blog_distribution.domain_name}"
}