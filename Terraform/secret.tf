resource "aws_ssm_parameter" "listenhost" {
  name  = "${var.project_name}_listenhost"
  type  = "String"
  value = "0.0.0.0"
}

resource "aws_ssm_parameter" "dbport" {
  name  = "${var.project_name}_dbport"
  type  = "String"
  value = "5432"
}

resource "aws_ssm_parameter" "dbtype" {
  name  = "${var.project_name}_dbtype"
  type  = "String"
  value = "postgres"
}

resource "aws_ssm_parameter" "dbhost" {
  name  = "${var.project_name}_dbhost"
  type  = "String"
  value = aws_db_instance.postgres.address
}

resource "aws_ssm_parameter" "listenport" {
  name  = "${var.project_name}_listenport"
  type  = "String"
  value = "3000"
}

resource "aws_secretsmanager_secret" "dbuser" {
  name = "${var.project_name}_dbuser2"
}

resource "aws_secretsmanager_secret" "dbpassword" {
  name = "${var.project_name}_dbpassword2"
}

resource "aws_secretsmanager_secret" "dbname" {
  name = "${var.project_name}_dbname2"
}


resource "aws_secretsmanager_secret_version" "dbuser" {
  secret_id     = aws_secretsmanager_secret.dbuser.id
  secret_string = var.dbuser
}

resource "aws_secretsmanager_secret_version" "dbpassword" {
  secret_id     = aws_secretsmanager_secret.dbpassword.id
  secret_string = var.dbpassword
}

resource "aws_secretsmanager_secret_version" "dbname" {
  secret_id     = aws_secretsmanager_secret.dbname.id
  secret_string = var.dbname
}