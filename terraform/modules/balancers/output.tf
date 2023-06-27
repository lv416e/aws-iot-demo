output "elb_name" {
  value = aws_elb.iot_elb.name
}

output "elb_dns_name" {
  value = aws_elb.iot_elb.dns_name
}
