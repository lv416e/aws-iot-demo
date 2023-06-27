output "lambda_invoke_arn" {
  value = aws_lambda_function.iot_lambda_api.invoke_arn
}