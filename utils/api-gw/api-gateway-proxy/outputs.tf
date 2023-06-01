output "api_gateway_url" {
  value = aws_api_gateway_stage.test.invoke_url
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api.id
}
