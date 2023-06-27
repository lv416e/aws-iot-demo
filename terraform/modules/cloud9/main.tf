#-------------------------------------------------------
# Cloud9
#-------------------------------------------------------
resource "aws_cloud9_environment_ec2" "iot_cl9" {
  name                        = "iot-cl9"
  description                 = "IoT Virtual Devices"
  instance_type               = "t2.micro"
  image_id                    = "amazonlinux-2-x86_64"
  subnet_id                   = var.subnet_id
  automatic_stop_time_minutes = 30
}

#-------------------------------------------------------
# Elastic IP for Cloud9
#-------------------------------------------------------
# resource "aws_eip" "iot_eip_cl9" {
#   domain   = "vpc"
#   instance = data.aws_instance.iot_cl9_instance.id
#   tags     = {
#     Name = "iot-eip-cl9"
#   }
# }