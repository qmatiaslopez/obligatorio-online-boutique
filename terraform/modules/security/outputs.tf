output "cluster_security_group_id" {
  description = "ID del security group del cluster"
  value       = aws_security_group.cluster.id
}

output "nodes_security_group_id" {
  description = "ID del security group de los nodes"
  value       = aws_security_group.nodes.id
}

output "alb_security_group_id" {
  description = "ID del security group del ALB"
  value       = aws_security_group.alb.id
}

output "pods_security_group_id" {
  description = "ID del security group de los pods"
  value       = aws_security_group.pods.id
}