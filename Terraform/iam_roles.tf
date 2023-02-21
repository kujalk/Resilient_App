resource "aws_iam_role" "ecs_role" {
  name = "${var.project_name}-ecs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs" {
  name = "${var.project_name}-ecs-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [ "${aws_ssm_parameter.listenhost.arn}",
      "${aws_ssm_parameter.dbport.arn}",
      "${aws_ssm_parameter.dbtype.arn}",
      "${aws_ssm_parameter.dbhost.arn}",
      "${aws_ssm_parameter.listenport.arn}"
      ],
      "Effect": "Allow"
    },
     {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": ["${aws_secretsmanager_secret.dbuser.arn}",
      "${aws_secretsmanager_secret.dbpassword.arn}",
      "${aws_secretsmanager_secret.dbname.arn}"],
      "Effect": "Allow"
    },
    {
      "Action": [
         "logs:CreateLogGroup",
         "logs:CreateLogStream",
         "logs:PutLogEvents"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-role-attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs.arn
}

//Autoscaling IAM role
resource "aws_iam_role" "ecs-autoscale-role" {
  name = "${var.project_name}-ecs-scale-policy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-autoscale" {
  role       = aws_iam_role.ecs-autoscale-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}