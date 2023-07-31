output "cluster_ids" {
  value = module.ecs[*].cluster_id
}