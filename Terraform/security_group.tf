//Security Group for ECS
resource "aws_security_group" "ecs-service" {
  name        = "${var.project_name}_ECS_Service"
  description = "To allow Traffic to ECS Service"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}_ECS_Service"
  }

  ingress {
    description = "Traffic Allow for API"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outside"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#//Security group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}_ALB"
  description = "To allow Traffic to ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}_ALB"
  }

  ingress {
    description = "All HTTP Traffic Allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outside"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Security Group for RDS Postgres
resource "aws_security_group" "rds" {
  name = "${var.project_name}-postgres-sg"

  description = "${var.project_name}-postgres-security-group"
  vpc_id      = aws_vpc.main.id

  # Only postgres in
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-service.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
