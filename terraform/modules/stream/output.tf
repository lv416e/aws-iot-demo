output "iot_kinesis_name" {
  value = aws_kinesis_stream.iot_kinesis.name
}

output "iot_kinesis_arn" {
  value = aws_kinesis_stream.iot_kinesis.arn
}

output "iot_firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.iot_firehose.name
}

output "iot_firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.iot_firehose.arn
}