output "iam_role_lambda_arn" {
  value = aws_iam_role.iot_role_lambda.arn
}

output "iam_role_api_gw_arn" {
  value = aws_iam_role.iot_role_api_gw.arn
}

output "iam_role_logging_arn" {
  value = aws_iam_role.iot_role_logging.arn
}

output "iam_role_kinesis_arn" {
  value = aws_iam_role.iot_role_kinesis.arn
}

output "iam_role_firehose_arn" {
  value = aws_iam_role.iot_role_firehose.arn
}

output "iam_role_firehose_to_s3_arn" {
  value = aws_iam_role.iot_role_firehose_to_s3.arn
}

output "iam_role_timestream_arn" {
  value = aws_iam_role.iot_role_timestream.arn
}

output "iam_role_opensearch_arn" {
  value = aws_iam_role.iot_role_opensearch.arn
}

output "iam_instance_profile_arn" {
  value = aws_iam_instance_profile.iot_iam_instance_profile.arn
}