data "archive_file" "iot_lambda_streaming" {
  type        = "zip"
  source_dir  = "../${path.root}/lambdafunc/stream/lambda_function"
  output_path = "${path.root}/lambdafunc/stream/lambda_function.zip"
}

data "archive_file" "iot_lambda_api" {
  type        = "zip"
  source_dir  = "../${path.root}/lambdafunc/api/lambda_function"
  output_path = "${path.root}/lambdafunc/api/lambda_function.zip"
}

resource "aws_lambda_function" "iot_lambda" {
  function_name = "iot-lambda"
  role          = var.iam_role_lambda_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.iot_lambda_streaming.output_path
  source_code_hash = data.archive_file.iot_lambda_streaming.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_tbl_name
    }
  }
}

resource "aws_lambda_function" "iot_lambda_api" {
  function_name = "iot-lambda-api"
  role          = var.iam_role_lambda_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.iot_lambda_api.output_path
  source_code_hash = data.archive_file.iot_lambda_api.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_tbl_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "iot_event_trigger_kinesis" {
  function_name     = aws_lambda_function.iot_lambda.arn
  event_source_arn  = var.iot_kinesis_arn
  batch_size        = 100
  starting_position = "LATEST"
}