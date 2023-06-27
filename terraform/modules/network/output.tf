output "vpc_id" {
  value = aws_vpc.iot_vpc.id
}

output "vpc_arn" {
  value = aws_vpc.iot_vpc.arn
}

output "subnet_id" {
  value = aws_subnet.iot_public_subnet.id
}

output "availability_zones" {
  value = [
    aws_subnet.iot_public_subnet_grafana_1.availability_zone,
    aws_subnet.iot_public_subnet_grafana_2.availability_zone
  ]
}

output "subnet_ids_grafana" {
  value = [
    aws_subnet.iot_public_subnet_grafana_1.id,
    aws_subnet.iot_public_subnet_grafana_2.id
  ]
}