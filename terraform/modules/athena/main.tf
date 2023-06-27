resource "aws_athena_workgroup" "iot_athena_wg" {
  name          = "iot-athena-wg"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration {
      output_location = "s3://${var.s3_bucket_name}/athena/"
    }
  }
}

resource "aws_athena_database" "iot_athena_db" {
  name          = "iot_athena_db"
  bucket        = var.s3_bucket_id
  force_destroy = true
}

resource "aws_athena_named_query" "iot_athena_create_tbl" {
  name        = "iot-athena-create-tbl"
  description = "Create Table"
  workgroup   = aws_athena_workgroup.iot_athena_wg.name
  database    = aws_athena_database.iot_athena_db.name
  query       = templatefile(
    "${path.module}/template/create_tbl.sql",
    {
      athena_db_name  = aws_athena_database.iot_athena_db.name
      athena_tbl_name = "iot-athena-tbl"
      s3_bucket_name  = var.s3_bucket_name
    }
  )
}

#-------------------------------------------------------
# Execute query for table creation
#-------------------------------------------------------
# NOTE: Following code does not work on Apple Silicon (darwin_arm64)
# resource "null_resource" "initialize_db" {
#   provisioner "local-exec" {
#     command = <<-EOF
#       aws athena start-query-execution \
#         --work-group "${aws_athena_workgroup.iot_athena_wg.id}" \
#         --query-execution-context Database="${aws_athena_database.iot_athena_db.id}" \
#         --query-string "${replace(replace(replace(data.template_file.create_tbl.rendered, "`", "\\`"), "\"", "\\\""), "$", "\\$")}"
#     EOF
#   }
# }
#
# data "template_file" "create_tbl" {
#   template = file(
#     "${path.module}/template/create_tbl.sql",
#     {
#       athena_db_name  = aws_athena_database.iot_athena_db.name
#       athena_tbl_name = "iot-athena-tbl"
#       s3_bucket_name  = var.s3_bucket_name
#     }
#   )
# }