output "opensearch_endpoint" {
  value = aws_opensearch_domain.iot_opensearch.endpoint
}

output "opensearch_domain_arn" {
  value = aws_opensearch_domain.iot_opensearch.arn
}