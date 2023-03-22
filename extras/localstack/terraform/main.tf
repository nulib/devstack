terraform {
  required_providers {
    aws = {
      version = "~> 4.0"
    }
  }
}

variable "localstack_endpoint" {
  type = string
  default = "http://localhost:4566"
}

locals {
  devstack_root = "${path.cwd}/.."
}

provider "aws" {
  access_key                    = "fake"
  secret_key                    = "fake"
  region                        = "us-east-1"
  s3_use_path_style             = true
  skip_credentials_validation   = true
  skip_metadata_api_check       = true
  skip_requesting_account_id    = true
  
  endpoints {
    apigateway     = var.localstack_endpoint
    apigatewayv2   = var.localstack_endpoint
    cloudformation = var.localstack_endpoint
    cloudwatch     = var.localstack_endpoint
    cloudwatchlogs = var.localstack_endpoint
    dynamodb       = var.localstack_endpoint
    ec2            = var.localstack_endpoint
    es             = var.localstack_endpoint
    elasticache    = var.localstack_endpoint
    elasticsearch  = var.localstack_endpoint
    firehose       = var.localstack_endpoint
    iam            = var.localstack_endpoint
    kinesis        = var.localstack_endpoint
    lambda         = var.localstack_endpoint
    opensearch     = var.localstack_endpoint
    rds            = var.localstack_endpoint
    redshift       = var.localstack_endpoint
    route53        = var.localstack_endpoint
    s3             = var.localstack_endpoint
    secretsmanager = var.localstack_endpoint
    ses            = var.localstack_endpoint
    sns            = var.localstack_endpoint
    sqs            = var.localstack_endpoint
    ssm            = var.localstack_endpoint
    stepfunctions  = var.localstack_endpoint
    sts            = var.localstack_endpoint
  }
}

data "aws_vpc" "default_vpc" {
  default = true
}

resource "aws_security_group" "open" {
  name        = "open-to-all"
  description = "Everything Open"
  vpc_id      = data.aws_vpc.default_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}