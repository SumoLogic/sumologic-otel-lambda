variable "name" {
  type        = string
  description = "Name of created function and API Gateway"
  default     = "hello-java-awssdk-wrapper"
}

variable "layer_arn" {
  type        = string
  description = "ARN for the Lambda layer containing the OpenTelemetry collector extension"
}

variable "collector_endpoint" {
  type        = string
  description = "URL for the OpenTelemetry collector"
}

variable "architecture" {
  type        = string
  description = "Lambda function architecture, valid values are arm64 or x86_64"
  default     = "x86_64"
}

variable "tracing_mode" {
  type        = string
  description = "Lambda function tracing mode"
  default     = "PassThrough"
}

variable "function_package" {
  type    = string
  default = "../../../opentelemetry-lambda/java/sample-apps/aws-sdk/build/libs/aws-sdk-all.jar"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "language" {
  type    = string
  default = "java"
}
