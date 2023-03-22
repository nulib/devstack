data "aws_iam_policy_document" "elasticsearch_http_access" {
  statement {
    sid     = "allow-from-aws"
    effect  = "Allow"
    actions = ["es:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
  }
}

resource "aws_opensearch_domain" "elasticsearch" {
  domain_name       = "meadow-index"
  engine_version    = "OpenSearch_1.2"
  access_policies   = data.aws_iam_policy_document.elasticsearch_http_access.json

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  cluster_config {
    dedicated_master_enabled  = true
    instance_type             = "m3.medium.search"
    instance_count            = 1
  }

  lifecycle {
    ignore_changes = [
      cluster_config
    ]
  }
}
