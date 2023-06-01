output "api-gateway-url" {
  value = module.api-gateway.api_gateway_url
}

output "service-name" {
  value = module.java-hello-lambda-function.lambda_function_name
}
