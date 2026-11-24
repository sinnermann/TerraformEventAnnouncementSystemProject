data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Attach basic CloudWatch logging permissions
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Least-privilege policy scoped strictly to our S3 bucket and SNS topic
data "aws_iam_policy_document" "lambda_s3_sns" {
  statement {
    sid       = "AllowS3EventsJson"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.website.arn}/events.json"]
  }

  statement {
    sid       = "AllowSNSSubscribeAndPublish"
    effect    = "Allow"
    actions   = ["sns:Subscribe", "sns:Publish"]
    resources = [aws_sns_topic.event_announcements.arn]
  }
}

resource "aws_iam_role_policy" "lambda_s3_sns" {
  name   = "${var.project_name}-s3-sns-policy"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_s3_sns.json
}
