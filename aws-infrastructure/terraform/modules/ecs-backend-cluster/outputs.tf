output "cluster_id" {
  value = aws_ecs_cluster.ecs_backend_cluster.id
}

output "backend_ecs_lb_target_group_arn" {
  value = aws_lb_target_group.backend_ecs_lb_target_group.arn
}

output "load_balancer_dns" {
  value = aws_lb.backend_ecs_lb.dns_name
}