variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix used for naming resources"
  type        = string
  default     = "garage-events"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the static website"
  type        = string
}
