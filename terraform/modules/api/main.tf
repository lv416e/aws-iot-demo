resource "aws_api_gateway_rest_api" "iot_rest_api" {
  name = "iot-api-gw"
  body = templatefile(
    "${path.module}/template/definition.json",
    {
      lambda_invoke_arn = var.lambda_invoke_arn
      api_gw_role_arn   = var.api_gw_role_arn
    }
  )
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "iot_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.iot_rest_api.id
  triggers    = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.iot_rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "iot_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.iot_rest_api.id
  deployment_id = aws_api_gateway_deployment.iot_api_deploy.id
  stage_name    = "iot-api"
}