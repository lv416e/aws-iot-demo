#-------------------------------------------------------
# Launch Template
#-------------------------------------------------------
resource "aws_launch_template" "iot_launch_template" {
  name          = "iot-launch-template"
  image_id      = "ami-0331ebbf81138e4de"
  instance_type = "t3.micro"
  user_data     = filebase64("${path.module}/template/builder.sh")

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10
      volume_type = "gp3"
    }
  }

  network_interfaces {
    security_groups             = var.asg_sg_ids
    associate_public_ip_address = true
  }
}

#-------------------------------------------------------
# Auto-Scaling Group (ASG)
#-------------------------------------------------------
resource "aws_autoscaling_group" "iot_asg" {
  name                = "iot-autoscaling-group"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = var.asg_subnet_ids
  load_balancers      = [var.elb_name]
  force_delete        = true

  launch_template {
    id = aws_launch_template.iot_launch_template.id
  }
}

resource "aws_autoscaling_policy" "iot_asg_scale_out" {
  name                   = "iot-asg-scale-out"
  autoscaling_group_name = aws_autoscaling_group.iot_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "iot_asg_scale_in" {
  name                   = "iot-asg-scale-in"
  autoscaling_group_name = aws_autoscaling_group.iot_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  policy_type            = "SimpleScaling"
}
