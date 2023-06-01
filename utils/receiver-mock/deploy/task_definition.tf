data "aws_caller_identity" "current" {}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecsTaskRole.arn
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  memory                   = 2048
  cpu                      = 1024
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-container"
      image     = "public.ecr.aws/sumologic/kubernetes-tools:2.19.0"
      cpu       = 1024
      memory    = 2048
      essential = true
      command   = ["receiver-mock", "--store-traces", "--store-metrics"]
      logConfiguration = {
        logDriver = "awslogs"
        options : {
          awslogs-group         = "${aws_cloudwatch_log_group.log-group.id}"
          awslogs-region        = "${var.aws_region}"
          awslogs-stream-prefix = "${var.app_name}"
        }
      }
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl localhost:3000/spans-limit"
        ],
        interval    = 60
        timeout     = 5
        retries     = 3
        startPeriod = 180
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-task-definition"
    }
  )
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}
