output "device_thing_name" {
  value = aws_iot_thing.iot_thing.name
}

# output.tf "cert" {
#   value = tls_self_signed_cert.cert.cert_pem
# }
#
# output.tf "key" {
#   value     = tls_private_key.key.private_key_pem
#   sensitive = true
# }