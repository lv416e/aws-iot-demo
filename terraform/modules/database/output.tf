output "dynamodb_tbl_name" {
  value = aws_dynamodb_table.iot_dynamodb.name
}

output "timestream_db_name" {
  value = aws_timestreamwrite_database.iot_timestream_db.database_name
}

output "timestream_tbl_name" {
  value = aws_timestreamwrite_table.iot_timestream_tbl.table_name
}