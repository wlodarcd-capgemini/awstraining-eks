data "aws_iam_role" "loadtest_ecs_role" {
  name = "backend-ecs-task-role-${var.region}"
}

data "aws_iam_role" "loadtest_ecs_execution_role" {
  name = "backend-ecs-execution-role-${var.region}"
}

resource "aws_ecs_cluster_capacity_providers" "fargate_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_loadtest_cluster.name
  capacity_providers = [ "FARGATE" ]
}

# ECS Cluster for loadtest
resource "aws_ecs_cluster" "ecs_loadtest_cluster" {
  name = var.name

  tags = merge(
    var.common_tags,
    {
      "Name" = "ecs-loadtest-cluster"
    }
  )
}

resource "aws_ecs_service" "ecs_loadtest_service" {
  name            = var.name
  cluster         = aws_ecs_cluster.ecs_loadtest_cluster.id
  task_definition = aws_ecs_task_definition.ecs_loadtest_task.arn

  desired_count   = var.service_deployment_desired_task_count
  launch_type = "FARGATE"

  # configuration needed for awsvpc network mode for tasks
  network_configuration {
    subnets = var.subnets
    security_groups = [ var.sg_ecs_backend_id ]
    assign_public_ip = false
  }
  tags = var.common_tags
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "ecs_loadtest_log_group" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30

  tags = merge(
    var.common_tags,
    {
      "Name" = "ecs-backend-loadtest-log-group"
    }
  )
}

# Task Definition
resource "aws_ecs_task_definition" "ecs_loadtest_task" {
  family = var.name
  container_definitions = templatefile("../../../templates/loadtest-task.json.tpl", {
    name = "backend-loadtest"
    image = "${var.ecr_loadtest_url}:${var.ecr_loadtest_image_tag}"
    log_group = var.name
    load_test_url = var.load_test_url
    load_test_result_bucket_name = var.load_test_result_bucket_name
  })
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = data.aws_iam_role.loadtest_ecs_execution_role.arn
  task_role_arn = data.aws_iam_role.loadtest_ecs_role.arn
  cpu = var.ecs_loadtest_fargate_cpu
  memory = var.ecs_loadtest_fargate_memory

  tags = merge(
    var.common_tags,
    {
      "Name" = "ecs-loadtest-task"
    }
  )
}



