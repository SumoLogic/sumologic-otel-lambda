locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[-| |T|Z|:]/", "")
}

data "aws_caller_identity" "current" {}

module "nodejs-hello-lambda-function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = ">= 2.24.0"

  architectures = compact([var.architecture])
  function_name = "${var.name}-${replace(var.architecture, "_", "-")}-${local.timestamp_sanitized}"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_package         = false
  local_existing_package = var.function_package

  memory_size = 512
  timeout     = 30

  layers = compact([
    var.layer_arn,
  ])

  environment_variables = {
    AWS_LAMBDA_EXEC_WRAPPER     = "/opt/otel-handler"
    SUMO_OTLP_HTTP_ENDPOINT_URL = "http://${var.collector_endpoint}:3000/receiver"
    OTEL_RESOURCE_ATTRIBUTES    = "application=lambda-tests,cloud.account.id=${data.aws_caller_identity.current.account_id}"
    OTEL_TRACES_SAMPLER         = "always_on"
  }

  tracing_mode = var.tracing_mode

  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect = "Allow"
      actions = [
        "s3:ListAllMyBuckets"
      ]
      resources = [
        "*"
      ]
    }
  }
}

module "api-gateway" {
  source = "../../../utils/api-gw/api-gateway-proxy"

  name                = "${var.name}-${replace(var.architecture, "_", "-")}-${local.timestamp_sanitized}"
  function_name       = module.nodejs-hello-lambda-function.lambda_function_name
  function_invoke_arn = module.nodejs-hello-lambda-function.lambda_function_invoke_arn
  lambda_function     = module.nodejs-hello-lambda-function
}
