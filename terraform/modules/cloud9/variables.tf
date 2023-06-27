data "aws_instance" "iot_cl9_instance" {
  filter {
    name   = "tag:aws:cloud9:environment"
    values = [
      aws_cloud9_environment_ec2.iot_cl9.id
    ]
  }
}

variable "subnet_id" {
  description = "hoge"
}