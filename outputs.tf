output "website_url" {
  description = "Live S3 Static Website URL"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "api_endpoint" {
  description = "API Gateway HTTP Endpoint"
  value       = aws_apigatewayv2_api.events_api.api_endpoint
}
