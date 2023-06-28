#-------------------------------------------------------
# IoT Policy
#-------------------------------------------------------
resource "aws_iot_policy" "iot_policy" {
  name   = "iot-policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "*",
          "Resource" : "*"
        }
      ]
    }
  )
}

#-------------------------------------------------------
# Certifications for IoT Things
#-------------------------------------------------------
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem       = tls_private_key.key.private_key_pem
  validity_period_hours = 240
  allowed_uses          = []

  subject {
    common_name  = "example.com"
    organization = "test"
  }
}

resource "local_file" "cert" {
  content  = tls_self_signed_cert.cert.cert_pem
  filename = "${path.root}/keys/aws_iot_thing-certificate.pem.crt"
}

resource "local_file" "key" {
  content  = tls_private_key.key.private_key_pem
  filename = "${path.root}/keys/aws_iot_thing-private.pem.key"
}

resource "aws_iot_certificate" "iot_cert" {
  certificate_pem = trimspace(tls_self_signed_cert.cert.cert_pem)
  active          = true
}

resource "aws_iot_thing_principal_attachment" "iot_cert_attch" {
  thing     = aws_iot_thing.iot_thing.name
  principal = aws_iot_certificate.iot_cert.arn
}

resource "aws_iot_policy_attachment" "iot_policy_attch" {
  policy = aws_iot_policy.iot_policy.name
  target = aws_iot_certificate.iot_cert.arn
}

#-------------------------------------------------------
# Things
#-------------------------------------------------------
resource "random_id" "suffix_id" {
  byte_length = 8
}

resource "aws_iot_thing" "iot_thing" {
  # name = "iot-thing-${random_id.suffix_id.hex}"
  name = "iot-thing-20230624"

  attributes = {
    # Name = "iot-thing-${random_id.suffix_id.hex}"
    Name = "iot-thing-20230624"
  }
}

#-------------------------------------------------------
# Logging Options
#-------------------------------------------------------
resource "aws_iot_logging_options" "iot_log" {
  default_log_level = "INFO"
  role_arn          = var.iam_role_logging_arn
}

#-------------------------------------------------------
# Topic Rules
#-------------------------------------------------------
resource "aws_iot_topic_rule" "iot_topic_rule_kinesis" {
  name        = "iot_topic_rule_kinesis"
  description = "Kinesis Datastream Rule"
  enabled     = true
  sql         = "SELECT * FROM 'data/${aws_iot_thing.iot_thing.name}'"
  sql_version = "2016-03-23"

  kinesis {
    stream_name   = var.iot_kinesis_name
    role_arn      = var.iam_role_kinesis_arn
    partition_key = "$${newuuid()}"
  }
}

resource "aws_iot_topic_rule" "iot_topic_rule_firehose" {
  name        = "iot_topic_rule_firehose"
  description = "Kinesis Firehose Datastream Rule"
  enabled     = true
  sql         = "SELECT * FROM 'data/${aws_iot_thing.iot_thing.name}'"
  sql_version = "2016-03-23"

  firehose {
    delivery_stream_name = var.iot_firehose_name
    role_arn             = var.iam_role_firehose_arn
    separator            = "\n"
  }
}

resource "aws_iot_topic_rule" "iot_topic_rule_timestream" {
  name        = "iot_topic_rule_timestream"
  description = "Amazon Timestream DB Rule"
  enabled     = true
  sql         = "SELECT HUMIDITY, TEMPERATURE FROM 'data/${aws_iot_thing.iot_thing.name}'"
  sql_version = "2016-03-23"

  timestream {
    database_name = var.iot_timestream_db_name
    table_name    = var.iot_timestream_tbl_name
    role_arn      = var.iam_role_timestream_arn

    dimension {
      name  = "DEVICE_NAME"
      value = "$${topic(2)}"
    }
  }
}

resource "aws_iot_topic_rule" "iot_topic_rule_opensearch" {
  name        = "iot_topic_rule_opensearch"
  description = "OpenSearch Rule"
  enabled     = true
  sql         = "SELECT TIMESTAMP as timestamp, HUMIDITY, TEMPERATURE, DEVICE_NAME FROM 'data/${aws_iot_thing.iot_thing.name}'"
  sql_version = "2016-03-23"

  elasticsearch {
    endpoint = "https://${var.opensearch_endpoint}"
    role_arn = var.iam_role_opensearch_arn
    id       = "$${newuuid()}"
    index    = "timestamp"
    type     = "timestamp"
  }
}
