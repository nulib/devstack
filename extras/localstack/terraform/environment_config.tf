locals {
  project       = "meadow"
  port_offset   = terraform.workspace == "test" ? 2 : 1
}

resource "aws_secretsmanager_secret" "db_secrets" {
  name    = "${local.project}/db"
  description = "Database configuration secrets"
}

resource "aws_secretsmanager_secret" "index_secrets" {
  name    = "${local.project}/index"
  description = "OpenSearch index secrets"
}

resource "aws_secretsmanager_secret" "ldap_secrets" {
  name    = "${local.project}/ldap"
  description = "LDAP server secrets"
}

resource "aws_secretsmanager_secret" "config_secrets" {
  name    = "${local.project}/config"
  description = "Miscellaneous configuration secrets"
}

resource "aws_secretsmanager_secret" "user_secrets" {
  name    = "${local.project}/config/${terraform.workspace}"
  description = "User-specific configuration secrets"
}

resource "aws_secretsmanager_secret" "ssl_certificate" {
  name = "${local.project}/ssl"
  description = "Wildcard SSL certificate and private key"
}

resource "aws_secretsmanager_secret_version" "db_secrets" {
  secret_id = aws_secretsmanager_secret.db_secrets.id
  secret_string = jsonencode({
    host        = "localhost"
    port        = 5432 + local.port_offset
    user        = "docker"
    password    = "d0ck3r"
  })
}

resource "aws_secretsmanager_secret_version" "index_secrets" {
  secret_id = aws_secretsmanager_secret.index_secrets.id
  secret_string = jsonencode({
    index_endpoint    = "http://localhost:${9200 + local.port_offset}"
    kibana_endpoint   = "http://localhost:${5601 + local.port_offset}"
  })
}

resource "aws_secretsmanager_secret_version" "ldap_secrets" {
  secret_id = aws_secretsmanager_secret.ldap_secrets.id
  secret_string = jsonencode({
    host       = "localhost"
    base       = "DC=library,DC=northwestern,DC=edu"
    port       = 389 + local.port_offset
    user_dn    = "cn=Administrator,cn=Users,dc=library,dc=northwestern,dc=edu"
    password   = "d0ck3rAdm1n!"
    ssl        = "false"
  })
}

resource "aws_secretsmanager_secret_version" "config_secrets" {
  secret_id = aws_secretsmanager_secret.config_secrets.id
  secret_string = jsonencode(var.config_secrets)
}

resource "aws_secretsmanager_secret_version" "user_secrets" {
  secret_id = aws_secretsmanager_secret.user_secrets.id
  secret_string = jsonencode(var.user_secrets)
}

resource "aws_secretsmanager_secret_version" "ssl_certificate" {
  secret_id       = aws_secretsmanager_secret.ssl_certificate.id
  secret_string   = jsonencode({
    certificate = file(var.ssl_certificate_file)
    key         = file(var.ssl_key_file)
  })
}
