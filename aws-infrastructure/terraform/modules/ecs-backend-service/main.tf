################ ecs-task-role ################

resource "aws_iam_role" "ecs_task_role" {
  name = "backend-ecs-task-role-${var.region}"
  assume_role_policy = file("../../../policies/ecs-assume-role-policy.json")
}

resource "aws_secretsmanager_secret" "secrets_manager" {
  name = "backend-secretsmanager-${var.environment}-${var.region}"
  tags = var.common_tags
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name = "backend-ecs-task-role-policy-${var.region}"
  policy = templatefile("../../../policies/ecs-task-role-policy.tpl", {
    secrets_manager_resources = [ aws_secretsmanager_secret.secrets_manager.arn ]
    region = var.region
    account_id = var.account_id
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attach" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

################ ecs-execution-role ################

resource "aws_iam_role" "ecs_execution_role" {
  name = "backend-ecs-execution-role-${var.region}"
  assume_role_policy = file("../../../policies/ecs-assume-role-policy.json")
}

resource "aws_iam_policy" "ecs_execution_role_policy" {
  name = "backend-ecs-execution-role-policy-${var.region}"
  policy = templatefile("../../../policies/ecs-execution-role-policy.tpl", {
    secrets_manager_resources = [ aws_secretsmanager_secret.secrets_manager.arn ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attach" {
  role = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_role_policy.arn
}

data "template_file" "service_template" {
  template = file("../../../templates/backend-container-definition.json.tpl")

  vars = {
    name = "backend"
    image = "${var.ecr_repository_url}:latest"
    log_group = "backend"
    secrets_arn = aws_secretsmanager_secret.secrets_manager.arn
    hub = var.hub
    environment = var.environment
    region = var.region
  }
}

# Task Definition
resource "aws_ecs_task_definition" "ecs_backend_task" {
  family = "backend"
  container_definitions = data.template_file.service_template.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  cpu = 1024
  memory = 2048

  tags = merge(
    var.common_tags,
    {
      Name = "ecs-backend-task"
    }
  )
}

resource "aws_ecs_service" "ecs_backend_service" {
  name = var.service_name
  cluster = var.ecs_backend_cluster_id
  desired_count = var.service_deployment_desired_task_count
  deployment_maximum_percent = var.service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent
  launch_type = "FARGATE"

  # configuration needed for awsvpc network mode for tasks
  network_configuration {
    subnets = var.subnets
    security_groups = [ var.sg_ecs_backend_id ]
    assign_public_ip = false
  }

  #load balancer
  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name = "backend"
    container_port = 8081
  }

  task_definition = aws_ecs_task_definition.ecs_backend_task.arn

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  tags = var.common_tags
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "ecs_backend_log_group" {
  name = "/ecs/${var.service_name}"
  retention_in_days = 30
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_utilization" {
  alarm_name = "backend-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  datapoints_to_alarm = "2"
  evaluation_periods = "2"
  statistic = "Average"
  threshold = "80"
  alarm_description = "Region=${var.region}; Env=${var.environment}; Desc=The CPU utilization of backend is above 80%"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "missing"
  dimensions = {
    ClusterName = "backend-ecs-${var.environment}"
    ServiceName = aws_ecs_service.ecs_backend_service.name
  }
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "backend_memory_utilization" {
  alarm_name = "backend-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name = "MemoryUtilization"
  namespace = "AWS/ECS"
  period = "60"
  datapoints_to_alarm = "2"
  evaluation_periods = "2"
  statistic = "Average"
  threshold = "80"
  alarm_description = "Region=${var.region}; Env=${var.environment}; Desc=The memory utilization of backend is above 80%"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "missing"
  dimensions = {
    ClusterName = "backend-ecs-${var.environment}"
    ServiceName = aws_ecs_service.ecs_backend_service.name
  }
  tags = var.common_tags
}