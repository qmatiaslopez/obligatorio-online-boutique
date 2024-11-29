data "aws_eks_cluster" "main" {
  name = "${var.project_name}-${var.environment}"
}

data "aws_security_group" "eks_cluster" {
  id = data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}