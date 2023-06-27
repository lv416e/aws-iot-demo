resource "aws_opensearch_domain" "iot_opensearch" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_count = 1
    instance_type  = "t3.small.search"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 10
  }

  cognito_options {
    enabled          = false
    identity_pool_id = ""
    role_arn         = ""
    user_pool_id     = ""
  }

  domain_endpoint_options {
    custom_endpoint_enabled = false
    enforce_https           = true
    tls_security_policy     = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled = false
  }

  node_to_node_encryption {
    enabled = false
  }

  advanced_security_options {
    enabled = false
  }
}

resource "aws_opensearch_domain_policy" "iot_opensearch_policy" {
  domain_name     = aws_opensearch_domain.iot_opensearch.domain_name
  access_policies = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : "es:*",
          "Resource" : "arn:aws:es:${var.aws_region_name}:${var.aws_account_id}:domain/${var.domain_name}/*",
          "Condition" : {
            "IpAddress" : {
              "aws:SourceIp" : replace(data.http.ipv4.response_body, "\n", "")
            }
          }
        }
      ]
    }
  )
}