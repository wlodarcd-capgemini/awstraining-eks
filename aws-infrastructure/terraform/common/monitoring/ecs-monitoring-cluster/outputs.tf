output "cluster_id" {
  value = module.ecs_monitoring_cluster.cluster_id
}
output "kibana_target_group_arn" {
  value = module.ecs_monitoring_cluster.kibana_target_group_arn
}

output "prometheus_target_group_arn" {
  value = module.ecs_monitoring_cluster.prometheus_target_group_arn
}

output "grafana_target_group_arn" {
  value = module.ecs_monitoring_cluster.grafana_target_group_arn
}

output "sg_monitoring_id" {
  value = module.ecs_monitoring_cluster.sg_monitoring_id
}