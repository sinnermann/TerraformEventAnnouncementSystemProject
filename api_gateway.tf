resource "aws_apigatewayv2_api" "events_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.events_api.id
  name        = "$default"
  auto_deploy = true
}

# --- /subscribe Integration & Route ---
resource "aws_apigatewayv2_integration" "subscribe" {
  api_id                 = aws_apigatewayv2_api.events_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.subscribe.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "subscribe" {
  api_id    = aws_apigatewayv2_api.events_api.id
  route_key = "POST /subscribe"
  target    = "integrations/${aws_apigatewayv2_integration.subscribe.id}"
}

resource "aws_lambda_permission" "api_subscribe" {
  statement_id  = "AllowAPIGatewayInvokeSubscribe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe.function_name
  principal     = join(".", ["apigateway", "amazonaws", "com"])
  source_arn    = "${aws_apigatewayv2_api.events_api.execution_arn}/*/*"
}

# --- /create-event Integration & Route ---
resource "aws_apigatewayv2_integration" "create_event" {
  api_id                 = aws_apigatewayv2_api.events_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.create_event.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_event" {
  api_id    = aws_apigatewayv2_api.events_api.id
  route_key = "POST /create-event"
  target    = "integrations/${aws_apigatewayv2_integration.create_event.id}"
}

resource "aws_lambda_permission" "api_create_event" {
  statement_id  = "AllowAPIGatewayInvokeCreateEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_event.function_name
  principal     = join(".", ["apigateway", "amazonaws", "com"])
  source_arn    = "${aws_apigatewayv2_api.events_api.execution_arn}/*/*"
}
