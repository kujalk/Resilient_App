resource "aws_cloudwatch_log_group" "ecs" {
  name = "${var.project_name}_ecs_logs"

  tags = {
    Application = "${var.project_name}_ecs"
  }
}