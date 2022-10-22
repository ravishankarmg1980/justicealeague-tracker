variable "env" {
  description = "Depolyment environment"
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  //default     = "eu-west-1"
  default     = "us-east-1"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "master"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "ravishankarmg1980"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "justicealeague-tracker"
}

variable "static_web_bucket_name" {
  description = "S3 Bucket to deploy to"
  default     = "static-web-example-bucket-red"
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "static-web-example-artifacts-red"
}


variable "github_token" {
  default = "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"
}

output "web_public_url" {
  value = aws_s3_bucket.static_web_bucket.website_endpoint
}
