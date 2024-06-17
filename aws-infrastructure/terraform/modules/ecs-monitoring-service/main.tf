data "template_file" "service_template" {
  template = file("../../../templates/monitoring-container-definition.json.tpl")

  vars = {
    log_group = aws_cloudwatch_log_group.ecs_monitoring_log_group.name
    region = var.region
    ecr_url = var.ecr_repository_url
  }
}

data "aws_iam_role" "backend_ecs_role" {
  name = "backend-ecs-task-role-${var.region}"
}

data "aws_iam_role" "backend_monitoring_ecs_role" {
  name = "backend-monitoring-ecs-task-role-${var.region}"
}

resource "aws_ecs_task_definition" "ecs_monitoring_task" {
  family = var.service_name
  container_definitions = data.template_file.service_template.rendered
  network_mode = "awsvpc"
  execution_role_arn = data.aws_iam_role.backend_ecs_role.arn
  task_role_arn = data.aws_iam_role.backend_monitoring_ecs_role.arn
  requires_compatibilities = ["FARGATE"]
  memory = "8192"
  cpu = "2048"

  tags = var.common_tags
}

resource "aws_ecs_service" "ecs_monitoring_service" {
  name = var.service_name
  cluster = var.ecs_monitoring_cluster_id
  task_definition = aws_ecs_task_definition.ecs_monitoring_task.arn
  desired_count = 1
  health_check_grace_period_seconds = 30
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 50
  launch_type = "FARGATE"

  # configuration needed for awsvpc network mode for tasks
  network_configuration {
    subnets = var.subnets
    security_groups = [ var.sg_monitoring_id ]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.kibana_target_group_arn
    container_name = "kibana"
    container_port = 5601
  }

  load_balancer {
    target_group_arn = var.prometheus_target_group_arn
    container_name = "prometheus"
    container_port = 9090
  }

  load_balancer {
    target_group_arn = var.grafana_target_group_arn
    container_name = "grafana"
    container_port = 3000
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_monitoring_log_group" {
  name = "/ecs/${var.service_name}"
  retention_in_days = 30
  tags = var.common_tags
}