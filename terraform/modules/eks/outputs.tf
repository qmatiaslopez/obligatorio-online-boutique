output "cluster_id" {
  description = "EKS cluster ID"
  value = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster certificate authority data"
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_asg_name" {
  description = "Nombre del Auto Scaling Group del node group"
  value       = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}