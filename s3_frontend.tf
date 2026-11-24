resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true # Allows "terraform destroy" to delete the bucket even after events.json is modified!
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Upload index.html with the live API Gateway URL automatically injected!
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"

  content = templatefile("${path.module}/frontend/index.html", {
    api_base_url = aws_apigatewayv2_api.events_api.api_endpoint
  })
}

# Upload all other files in frontend/ (except index.html)
resource "aws_s3_object" "static_assets" {
  for_each = setsubtract(fileset("${path.module}/frontend", "**/*"), ["index.html"])

  bucket = aws_s3_bucket.website.id
  key    = each.value
  source = "${path.module}/frontend/${each.value}"
  etag   = filemd5("${path.module}/frontend/${each.value}")

  content_type = lookup({
    "html"  = "text/html",
    "css"   = "text/css",
    "js"    = "application/javascript",
    "json"  = "application/json",
    "jpg"   = "image/jpeg",
    "jpeg"  = "image/jpeg",
    "png"   = "image/png",
    "gif"   = "image/gif",
    "webp"  = "image/webp",
    "svg"   = "image/svg+xml",
    "ico"   = "image/x-icon",
    "woff"  = "font/woff",
    "woff2" = "font/woff2",
    "ttf"   = "font/ttf",
    "eot"   = "application/vnd.ms-fontobject"
  }, lower(element(split(".", each.value), length(split(".", each.value)) - 1)), "application/octet-stream")
}
