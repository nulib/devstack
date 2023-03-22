locals {
  project       = "meadow"

  computed_secrets = {
    db   = {
      host        = module.rds.db_instance_address
      port        = module.rds.db_instance_port
      user        = module.rds.db_instance_username
      password    = module.rds.db_instance_password
    }

    search = {
      cluster_endpoint    = "http://${aws_opensearch_domain.elasticsearch.endpoint}"
      kibana_endpoint   = "http://${aws_opensearch_domain.elasticsearch.kibana_endpoint}"
    }

    ldap = {
      host       = "localhost"
      base       = "DC=library,DC=northwestern,DC=edu"
      port       = 389
      user_dn    = "cn=Administrator,cn=Users,dc=library,dc=northwestern,dc=edu"
      password   = "d0ck3rAdm1n!"
      ssl        = "false"
    }
  }

  config_secrets = merge(var.config_secrets, local.computed_secrets)
}

resource "aws_secretsmanager_secret" "config_secrets" {
  name    = "config/meadow"
  description = "Meadow configuration secrets"
}

resource "aws_secretsmanager_secret" "ssl_certificate" {
  name = "config/wildcard_ssl"
  description = "Wildcard SSL certificate and private key"
}

resource "aws_secretsmanager_secret_version" "config_secrets" {
  secret_id = aws_secretsmanager_secret.config_secrets.id
  secret_string = jsonencode(local.config_secrets)
}

resource "aws_secretsmanager_secret_version" "ssl_certificate" {
  secret_id       = aws_secretsmanager_secret.ssl_certificate.id
  secret_string   = jsonencode({
    certificate = file(var.ssl_certificate_file)
    key         = file(var.ssl_key_file)
  })
}
