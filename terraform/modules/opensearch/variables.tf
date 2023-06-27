data "http" "ipv4" {
  url = "http://checkip.amazonaws.com"
}

variable "domain_name" {
  default = "iot-opensearch"
}

variable "aws_account_id" {
  description = "hoge"
}

variable "aws_region_name" {
  description = "hoge"
}