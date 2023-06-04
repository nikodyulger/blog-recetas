resource "aws_s3_bucket" "blog_bucket" {
  bucket = "blog-recetas-para-sobrevir"
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
    key = "error.html"
  }
}

data "aws_iam_policy_document" "blog_bucket_policy_data" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.blog_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.blog_oai_s3_cdn.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "blog_bucket_policy" {
  bucket = aws_s3_bucket.blog_bucket.id
  policy = data.aws_iam_policy_document.blog_bucket_policy_data.json

  depends_on = [
    aws_cloudfront_origin_access_identity.blog_oai_s3_cdn
  ]
}