#-------------------------------------------------------
# Kinesis Datastream
#-------------------------------------------------------
resource "aws_kinesis_stream" "iot_kinesis" {
  name = "iot-kinesis"

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

#-------------------------------------------------------
# Kinesis Firehose Datastream
#-------------------------------------------------------
resource "aws_kinesis_firehose_delivery_stream" "iot_firehose" {
  name        = "iot-firehose"
  destination = "extended_s3"

  server_side_encryption {
    enabled = false
  }

  extended_s3_configuration {
    bucket_arn          = var.s3_bucket_arn
    role_arn            = var.iam_role_firehose_to_s3_arn
    buffer_size         = 5   # only hashicorp/aws < 5.0.0
    buffer_interval     = 60  # only hashicorp/aws < 5.0.0
    compression_format  = "GZIP"
    prefix              = "logs/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/"
    error_output_prefix = "logs-error/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{firehose:error-output-type}/"
  }
}
