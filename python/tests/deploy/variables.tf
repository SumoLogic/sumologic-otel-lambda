variable "name" {
  type        = string
  description = "Name of created function and API Gateway"
  default     = "sumo-hello-python"
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

variable "runtime" {
  type        = string
  description = "Python runtime version used for sample Lambda Function"
  default     = "python3.9"
}

variable "tracing_mode" {
  type        = string
  description = "Lambda function tracing mode"
  default     = "PassThrough"
}

variable "function_package" {
  type    = string
  default = "../../../opentelemetry-lambda/python/sample-apps/build/function.zip"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "language" {
  type    = string
  default = "python"
}
