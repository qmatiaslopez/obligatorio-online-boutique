# EKS Cluster
resource "aws_eks_cluster" "main" {
  name = "${var.project_name}-${var.environment}"
  role_arn = "arn:aws:iam::184699688245:role/LabRole"
  version = var.cluster_version

  vpc_config {
    security_group_ids = [var.cluster_sg_id]
    subnet_ids = concat(var.private_subnets, var.public_subnets)
    endpoint_private_access = true
    endpoint_public_access = true
  }

  tags = var.tags
}

# Node Group
resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodes-${var.environment}"
  node_role_arn = "arn:aws:iam::184699688245:role/LabRole"
  subnet_ids = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size = 4
    min_size = 2
  }

  instance_types = ["m5.large"]

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role" = "general"
  }

  tags = var.tags
}