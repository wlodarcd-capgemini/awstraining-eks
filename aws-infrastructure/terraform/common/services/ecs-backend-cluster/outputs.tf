output "cluster_id" {
  value = module.ecs_backend_cluster.cluster_id
}

output "backend_ecs_lb_target_group_arn" {
  value = module.ecs_backend_cluster.backend_ecs_lb_target_group_arn
}

output "load_balancer_dns" {
  value = module.ecs_backend_cluster.load_balancer_dns
}