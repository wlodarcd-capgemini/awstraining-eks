resource "aws_iam_role" "ecs_monitoring_task_role" {
  name = "backend-monitoring-ecs-task-role-${var.region}"
  assume_role_policy = file("../../../policies/ecs-assume-role-policy.json")
}

resource "aws_iam_policy" "ecs_monitoring_task_role_policy" {
  name = "backend-monitoring-ecs-task-role-${var.region}"
  policy = file("../../../policies/ecs-monitoring-task-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_monitoring_task_role_attach" {
  role = aws_iam_role.ecs_monitoring_task_role.name
  policy_arn = aws_iam_policy.ecs_monitoring_task_role_policy.arn
}

resource "aws_security_group" "sg_monitoring" {
  description = "Controls direct access to monitoring applications instances"
  vpc_id = var.vpc_id
  name = "sg_backend_monitoring"

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 5601
    to_port = 5601
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = merge(
    {
      Terraform = "true"
      Environment = var.environment
      Name = "SG Monitoring"
    }
  )
}

resource "aws_ecs_cluster" "ecs_monitoring_cluster" {
  name = var.ecs_cluster_name
  tags = var.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "fargate_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_monitoring_cluster.name
  capacity_providers = [ "FARGATE" ]
}

resource "aws_lb" "monitoring_lb" {
  name = "monitoring-lb"
  internal = false
  load_balancer_type = "network"
  enable_deletion_protection = false

  subnets = var.subnets
  tags = var.common_tags
}

resource "aws_lb_listener" "kibana_lb_listener" {
  load_balancer_arn = aws_lb.monitoring_lb.arn
  port = "5601"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.kibana_target_group.arn
  }
  tags = var.common_tags
}

resource "aws_lb_target_group" "kibana_target_group" {
  name = "kibana-tg"
  port = 5601
  protocol = "TCP"
  target_type = "ip"
  vpc_id = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/api/status"
    protocol            = "HTTP"
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "prometheus_lb_listener" {
  load_balancer_arn = aws_lb.monitoring_lb.arn
  port = "9090"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.prometheus_target_group.arn
  }
  tags = var.common_tags
}

resource "aws_lb_target_group" "prometheus_target_group" {
  name = "prometheus-tg"
  port = 9090
  protocol = "TCP"
  target_type = "ip"
  vpc_id = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/-/healthy"
    protocol            = "HTTP"
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "grafana_lb_listener" {
  load_balancer_arn = aws_lb.monitoring_lb.arn
  port = "3000"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.grafana_target_group.arn
  }
  tags = var.common_tags
}

resource "aws_lb_target_group" "grafana_target_group" {
  name = "grafana-tg"
  port = 3000
  protocol = "TCP"
  target_type = "ip"
  vpc_id = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/api/health"
    protocol            = "HTTP"
  }

  tags = var.common_tags
}