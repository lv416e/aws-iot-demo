#-------------------------------------------------------
# DynamoDB
#-------------------------------------------------------
resource "aws_dynamodb_table" "iot_dynamodb" {
  name      = "iot-dynamodb"
  hash_key  = "deviceid"
  range_key = "timestamp"

  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "deviceid"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

#-------------------------------------------------------
# Amazon Timestream Database
#-------------------------------------------------------
resource "aws_timestreamwrite_database" "iot_timestream_db" {
  database_name = "iot-timestream-db"
}

resource "aws_timestreamwrite_table" "iot_timestream_tbl" {
  database_name = aws_timestreamwrite_database.iot_timestream_db.database_name
  table_name    = "iot-timestream-tbl"

  retention_properties {
    magnetic_store_retention_period_in_days = 1
    memory_store_retention_period_in_hours  = 1
  }
}