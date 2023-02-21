#Subnets of RDS
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}_db_subnet_group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "${var.project_name}_db_subnet_group"
  }
}

#RDS
resource "aws_db_instance" "postgres" {
  allocated_storage       = var.disk_size
  storage_type            = var.storage_type
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_size
  db_name                 = var.dbname
  username                = var.dbuser
  password                = var.dbpassword
  backup_retention_period = 0
  identifier              = "${var.project_name}-postgres-server"
  publicly_accessible     = "false"
  skip_final_snapshot     = "true"
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name

}

