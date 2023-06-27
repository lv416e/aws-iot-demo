#-------------------------------------------------------
# Provider Configurations & Requirements
#-------------------------------------------------------
terraform {
  required_version = "~> 1.5.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "terraform"
}

#-------------------------------------------------------
# Variables
#-------------------------------------------------------
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  s3_bucket_name = "iot-bucket-20230624"
}

#-------------------------------------------------------
# Modules
#-------------------------------------------------------
module "network" {
  source = "./modules/network"
}

module "permissions" {
  source                = "./modules/permissions"
  firehose_stream_name  = module.stream.iot_firehose_name
  timestream_db_name    = module.database.timestream_db_name
  timestream_tbl_name   = module.database.timestream_tbl_name
  opensearch_domain_arn = module.opensearch.opensearch_domain_arn
  s3_bucket_name        = local.s3_bucket_name
  aws_account_id        = data.aws_caller_identity.current.account_id
  aws_region_name       = data.aws_region.current.name
}

module "security" {
  source  = "./modules/security"
  vpc_id  = module.network.vpc_id
  vpc_arn = module.network.vpc_arn
}

module "bucket" {
  source         = "./modules/bucket"
  s3_bucket_name = local.s3_bucket_name
}

module "database" {
  source = "./modules/database"
}

module "stream" {
  source                      = "./modules/stream"
  s3_bucket_arn               = module.bucket.s3_bucket_arn
  iam_role_firehose_to_s3_arn = module.permissions.iam_role_firehose_to_s3_arn
}

module "iot" {
  source                  = "./modules/iot"
  iam_role_logging_arn    = module.permissions.iam_role_logging_arn
  iam_role_kinesis_arn    = module.permissions.iam_role_kinesis_arn
  iam_role_firehose_arn   = module.permissions.iam_role_firehose_arn
  iam_role_timestream_arn = module.permissions.iam_role_timestream_arn
  iam_role_opensearch_arn = module.permissions.iam_role_opensearch_arn
  iot_kinesis_name        = module.stream.iot_kinesis_name
  iot_firehose_name       = module.stream.iot_firehose_name
  iot_timestream_db_name  = module.database.timestream_db_name
  iot_timestream_tbl_name = module.database.timestream_tbl_name
  opensearch_endpoint     = module.opensearch.opensearch_endpoint
}

module "lambda" {
  source              = "./modules/lambda"
  iam_role_lambda_arn = module.permissions.iam_role_lambda_arn
  iot_kinesis_name    = module.stream.iot_kinesis_name
  iot_kinesis_arn     = module.stream.iot_kinesis_arn
  dynamodb_tbl_name   = module.database.dynamodb_tbl_name
}

module "balancers" {
  source         = "./modules/balancers"
  elb_vpc_id     = module.network.vpc_id
  elb_subnet_ids = module.network.subnet_ids_grafana
  elb_sg_ids     = module.security.elb_sg_ids
}

module "instances" {
  source                   = "./modules/instances"
  iam_instance_profile_arn = module.permissions.iam_instance_profile_arn
  asg_sg_ids               = module.security.asg_sg_ids
  asg_subnet_ids           = module.network.subnet_ids_grafana
  elb_name                 = module.balancers.elb_name
}

module "opensearch" {
  source          = "./modules/opensearch"
  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_region_name = data.aws_region.current.name
}

module "athena" {
  source         = "./modules/athena"
  s3_bucket_name = local.s3_bucket_name
  s3_bucket_id   = module.bucket.s3_bucket_id
}

module "api" {
  source            = "./modules/api"
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  api_gw_role_arn   = module.permissions.iam_role_api_gw_arn
}

module "cloud9" {
  source    = "./modules/cloud9"
  subnet_id = module.network.subnet_id
}

#-------------------------------------------------------
# Global Outputs
#-------------------------------------------------------
output "cloud9_url" {
  value = module.cloud9.url
}

output "elb_url" {
  value = "http://${module.balancers.elb_dns_name}"
}

output "api_url" {
  value = module.api.invoke_url
}

output "device_thing_name" {
  value = module.iot.device_thing_name
}
