#-------------------------------------------------------
# IAM POLICY & ROLE FOR LAMBDA
#-------------------------------------------------------
resource "aws_iam_role" "iot_role_lambda" {
  name               = "iot-role-lambda"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole"
          ],
          "Principal" : {
            "Service" : [
              "lambda.amazonaws.com"
            ]
          }
        }
      ]
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
  ]
}

#-------------------------------------------------------
# IAM Role for API Gateway
#-------------------------------------------------------
resource "aws_iam_role" "iot_role_api_gw" {
  name                = "iot-role-api-gw"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole",
  ]
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "apigateway.amazonaws.com"
            ]
          },
          "Action" : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )
}

#-------------------------------------------------------
# IAM Policy & Role for IoT Logging
#-------------------------------------------------------
resource "aws_iam_policy" "iot_policy_logging" {
  name   = "iot-policy-logging"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ],
          "Resource" : [
            "arn:aws:logs:*:log-group:*:log-stream:*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role" "iot_role_logging" {
  name               = "iot-role-logging"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "iot.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "iot_role_policy_logging" {
  role       = aws_iam_role.iot_role_logging.name
  policy_arn = aws_iam_policy.iot_policy_logging.arn
}

#-------------------------------------------------------
# IAM Policy & Role for IoT Kinesis Datastream
#-------------------------------------------------------
resource "aws_iam_role" "iot_role_kinesis" {
  name               = "iot-role-kinesis"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "iot.amazonaws.com"
            ]
          },
          "Action" : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSIoTRuleActions",
    "arn:aws:iam::aws:policy/service-role/AWSIoTLogging",
    "arn:aws:iam::aws:policy/service-role/AWSIoTThingsRegistration",
  ]
}

#-------------------------------------------------------
# IAM Policy & Role for IoT Kinesis Firehose
#-------------------------------------------------------
resource "aws_iam_policy" "iot_policy_firehose" {
  name   = "iot-policy-firehose"
  policy = templatefile(
    "${path.module}/template/policy_firehose.json",
    {
      firehose_stream_name = var.firehose_stream_name
      aws_region_name      = var.aws_region_name
      aws_account_id       = var.aws_account_id
    }
  )
}

resource "aws_iam_role" "iot_role_firehose" {
  name               = "iot-role-firehose"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "iot.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "iot_role_policy_firehose" {
  role       = aws_iam_role.iot_role_firehose.name
  policy_arn = aws_iam_policy.iot_policy_firehose.arn
}

#-------------------------------------------------------
# IAM Policy & Role for Firehose to S3
#-------------------------------------------------------
resource "aws_iam_policy" "iot_policy_firehose_to_s3" {
  name   = "iot-policy-firehose-to-s3"
  policy = templatefile(
    "${path.module}/template/policy_firehose_to_s3.json",
    {
      firehose_stream_name = var.firehose_stream_name
      s3_bucket_name       = var.s3_bucket_name
      aws_region_name      = var.aws_region_name
      aws_account_id       = var.aws_account_id
    }
  )
}

resource "aws_iam_role" "iot_role_firehose_to_s3" {
  name               = "iot-role-firehose-to-s3"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "firehose.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "iot_role_policy_firehose_to_s3" {
  role       = aws_iam_role.iot_role_firehose_to_s3.name
  policy_arn = aws_iam_policy.iot_policy_firehose_to_s3.arn
}

#-------------------------------------------------------
# IAM Policy & Role for Amazon Timestream
#-------------------------------------------------------
resource "aws_iam_policy" "iot_policy_timestream" {
  name   = "iot-policy-timestream"
  policy = templatefile(
    "${path.module}/template/policy_timestream.json",
    {
      timestream_db_name  = var.timestream_db_name
      timestream_tbl_name = var.timestream_tbl_name
      aws_region_name     = var.aws_region_name
      aws_account_id      = var.aws_account_id
    }
  )
}

resource "aws_iam_role" "iot_role_timestream" {
  name               = "iot-role-timestream"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "iot.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "iot_role_policy_timestream" {
  role       = aws_iam_role.iot_role_timestream.name
  policy_arn = aws_iam_policy.iot_policy_timestream.arn
}

#-------------------------------------------------------
# IAM Policy & Role for Instances
#-------------------------------------------------------
resource "aws_iam_policy" "iot_policy_instances" {
  name   = "iot-policy-instances"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "timestream:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "iot_role_instances" {
  name               = "iot-role-instances"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "iot_role_policy_instances" {
  role       = aws_iam_role.iot_role_instances.name
  policy_arn = aws_iam_policy.iot_policy_instances.arn
}

resource "aws_iam_instance_profile" "iot_iam_instance_profile" {
  name = "iot-iam-instance-profile"
  role = aws_iam_role.iot_role_instances.name
}

#-------------------------------------------------------
# IAM Policy & Role for OpenSearch
#-------------------------------------------------------
resource "aws_iam_policy" "demo_policy_opensearch" {
  name   = "demo-policy-opensearch"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "es:ESHttpPut",
          "Resource" : ["${var.opensearch_domain_arn}/*"]
        }
      ]
    }
  )
}

resource "aws_iam_role" "iot_role_opensearch" {
  name               = "iot-role-opensearch"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "iot.amazonaws.com"
            ]
          },
          "Action" : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "iot_role_policy_opensearch" {
  role       = aws_iam_role.iot_role_opensearch.name
  policy_arn = aws_iam_policy.demo_policy_opensearch.arn
}