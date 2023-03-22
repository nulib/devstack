module "rds" {
  source                    = "terraform-aws-modules/rds/aws"
  version                   = "4.1.2"
  allocated_storage         = "10"
  engine                    = "postgres"
  engine_version            = "11.16"
  identifier                = "meadow-db"
  instance_class            = "db.t3.small"
  create_random_password    = false
  username                  = "docker"
  password                  = "d0ck3r"
  family                    = "postgres11"
  storage_encrypted         = false
  vpc_security_group_ids    = [aws_security_group.open.id]
}
