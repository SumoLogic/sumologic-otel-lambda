resource "aws_api_gateway_rest_api" "api" {
  name = var.name
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.name
  lifecycle {
    replace_triggered_by = [aws_api_gateway_rest_api.api.name]
  }
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
  lifecycle {
    replace_triggered_by = [aws_api_gateway_rest_api.api.name]
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy_method.resource_id
  http_method = aws_api_gateway_method.proxy_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.function_invoke_arn

  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [aws_api_gateway_rest_api.api.name]
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_resource.api_resource, aws_api_gateway_method.proxy_method, aws_lambda_permission.lambda_api_allow_gateway, aws_api_gateway_integration.lambda, var.lambda_function]
  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [aws_api_gateway_rest_api.api.name]
  }
}

resource "aws_api_gateway_stage" "test" {
  stage_name           = "default"
  rest_api_id          = aws_api_gateway_rest_api.api.id
  deployment_id        = aws_api_gateway_deployment.deployment.id
  xray_tracing_enabled = var.enable_xray_tracing

  lifecycle {
    replace_triggered_by = [aws_api_gateway_rest_api.api.name]
  }
}

resource "aws_lambda_permission" "lambda_api_allow_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
