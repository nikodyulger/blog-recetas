resource "aws_s3_bucket" "blog_bucket" {
  bucket = "blog-recetas-para-sobrevivir"
}

resource "aws_s3_bucket_versioning" "blog_bucket_versioning" {
  bucket = aws_s3_bucket.blog_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "blog_website_config_bucket" {
  bucket = aws_s3_bucket.blog_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

data "aws_iam_policy_document" "blog_bucket_policy_data" {
  statement {
    sid = "CloudfrontOAC"

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.blog_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.blog_distribution.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "blog_bucket_policy" {
  bucket = aws_s3_bucket.blog_bucket.id
  policy = data.aws_iam_policy_document.blog_bucket_policy_data.json

  depends_on = [
    aws_cloudfront_distribution.blog_distribution
  ]
}