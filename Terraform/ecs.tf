//ECS cluster
resource "aws_ecs_cluster" "fargate" {
  name = "${var.project_name}_fargate_cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.fargate.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

//Task definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project_name}_ecs_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  task_role_arn            = aws_iam_role.ecs_role.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = <<EOF
[
  {
    "name": "servian-app",
    "image": "${var.image_url}",
    "cpu": 256,
    "memory": 512,
    "command": ["serve"],
    "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.ecs.name}",
            "awslogs-region": "ap-southeast-1",
            "awslogs-stream-prefix": "ecs"
          }
    },
    "portMappings": [ 
             { 
                "containerPort": 3000,
                "hostPort": 3000,
                "protocol": "tcp"
             }
    ],
    "secrets": [{
      "name": "VTT_LISTENHOST",
      "valueFrom": "${aws_ssm_parameter.listenhost.arn}"
    },
    {
      "name": "VTT_DBPORT",
      "valueFrom": "${aws_ssm_parameter.dbport.arn}"
    },
    {
      "name": "VTT_DBTYPE",
      "valueFrom": "${aws_ssm_parameter.dbtype.arn}"
    },
    {
      "name": "VTT_DBHOST",
      "valueFrom": "${aws_ssm_parameter.dbhost.arn}"
    },
    {
      "name": "VTT_LISTENPORT",
      "valueFrom": "${aws_ssm_parameter.listenport.arn}"
    },
    {
      "name": "VTT_DBUSER",
      "valueFrom": "${aws_secretsmanager_secret.dbuser.arn}"
    },
    {
      "name": "VTT_DBPASSWORD",
      "valueFrom": "${aws_secretsmanager_secret.dbpassword.arn}"
    },
    {
      "name": "VTT_DBNAME",
      "valueFrom": "${aws_secretsmanager_secret.dbname.arn}"
    }
    ]
  }
]
EOF
}

//Enabling ALB
resource "aws_ecs_service" "go-api" {
  name            = "${var.project_name}_ecs_service"
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.test.arn
    container_name   = "servian-app"
    container_port   = 3000
  }

  network_configuration {
    subnets         = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_groups = [aws_security_group.ecs-service.id]
  }
}

//Enabling Autoscaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.fargate.name}/${aws_ecs_service.go-api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.ecs-autoscale-role.arn
}

//Autoscaling policy
resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  name               = "${var.project_name}_ecs_cpu_scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}
resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name               = "${var.project_name}_ecs_memory_scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}