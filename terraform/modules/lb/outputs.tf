output "nlb_dns_name" {
  description = "DNS name del Network Load Balancer"
  value       = aws_lb.frontend.dns_name
}

output "target_group_arn" {
  description = "ARN del target group del frontend"
  value       = aws_lb_target_group.frontend.arn
}

output "nlb_arn" {
  description = "ARN del Network Load Balancer"
  value       = aws_lb.frontend.arn
}

output "target_group_name" {
  description = "Nombre del target group"
  value       = aws_lb_target_group.frontend.name
}