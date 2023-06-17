data "aws_iam_policy_document" "lambda_edge_policy" {
  statement {
    sid = "LambdaEdgeSTSPolicy"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_edge_role" {
  name               = "lambda-edge-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_policy.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_edge/cdn_redirection.js"
  output_path = "lambda_edge.zip"
}

resource "aws_lambda_function" "lambda_edge" {

  function_name = "cdn_redirection"
  filename      = "lambda_edge.zip"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "cdn_redirection.handler"
  runtime       = "nodejs16.x"
  publish       = "true"
  provider      = aws.north_virginia_region
}
