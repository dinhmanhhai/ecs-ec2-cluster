output "cluster_ids" {
  value = module.ecs[*].cluster_id
}

output "cluster_name_map_id" {
  value = tomap({
    for i, id in var.cluster_names :
    id => module.ecs[i].cluster_id
  })
}