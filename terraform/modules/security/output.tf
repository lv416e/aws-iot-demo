output "asg_sg_ids" {
  value = [aws_security_group.iot_server_sg.id]
}

output "elb_sg_ids" {
  value = [aws_security_group.iot_balancer_sg.id]
}