resource "aws_security_group_rule" "eks_cluster_ingress_alb" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.eks_cluster.id
  source_security_group_id = var.alb_security_group_id
  description             = "Allow traffic from ALB to EKS NodePort"
}