output "cluster_id" {
  value = aws_ecs_cluster.ecs_monitoring_cluster.id
}

output "kibana_target_group_arn" {
  value = aws_lb_target_group.kibana_target_group.arn
}

output "prometheus_target_group_arn" {
  value = aws_lb_target_group.prometheus_target_group.arn
}

output "grafana_target_group_arn" {
  value = aws_lb_target_group.grafana_target_group.arn
}

output "sg_monitoring_id" {
  description = "Security group prometheus"
  value = aws_security_group.sg_monitoring.id
}

output "monitoring_lb_arn" {
  description = "Monitoring LB ARN"
  value = aws_lb.monitoring_lb.arn
}