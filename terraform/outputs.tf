output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnets
}

output "node_group_asg_name" {
  description = "Nombre del Auto Scaling Group del node group"
  value       = module.eks.node_group_asg_name
}

output "nlb_dns_name" {
  description = "DNS name del Network Load Balancer"
  value       = module.lb.nlb_dns_name
}

output "target_group_arn" {
  description = "ARN del target group del frontend"
  value       = module.lb.target_group_arn
}