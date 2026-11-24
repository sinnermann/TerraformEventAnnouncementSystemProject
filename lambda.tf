data "archive_file" "subscribe_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/subscribe.py"
  output_path = "${path.module}/.terraform/subscribe.zip"
}

data "archive_file" "create_event_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/create_event.py"
  output_path = "${path.module}/.terraform/create_event.zip"
}

resource "aws_lambda_function" "subscribe" {
  function_name    = "${var.project_name}-subscribe"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "subscribe.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.subscribe_zip.output_path
  source_code_hash = data.archive_file.subscribe_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_announcements.arn
    }
  }
}

resource "aws_lambda_function" "create_event" {
  function_name    = "${var.project_name}-create-event"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "create_event.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.create_event_zip.output_path
  source_code_hash = data.archive_file.create_event_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME   = aws_s3_bucket.website.id
      SNS_TOPIC_ARN = aws_sns_topic.event_announcements.arn
    }
  }
}
