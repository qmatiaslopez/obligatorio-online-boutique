# Security Group for the EKS Cluster
resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-cluster-sg-${var.environment}"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_name}-cluster-sg-${var.environment}"
    },
    var.tags
  )
}

# Security Group for Node Groups
resource "aws_security_group" "nodes" {
  name        = "${var.project_name}-nodes-sg-${var.environment}"
  description = "Security group for EKS node groups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_name}-nodes-sg-${var.environment}"
    },
    var.tags
  )
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg-${var.environment}"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_name}-alb-sg-${var.environment}"
    },
    var.tags
  )
}

# Security Group for Pods
resource "aws_security_group" "pods" {
  name        = "${var.project_name}-pods-sg-${var.environment}"
  description = "Security group for EKS pods"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_name}-pods-sg-${var.environment}"
    },
    var.tags
  )
}

# Regla ALB -> Cluster (NodePort)
resource "aws_security_group_rule" "alb_to_cluster_nodeport" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.alb.id
  description             = "Allow traffic from ALB to Cluster NodePort 30080"
}

# Reglas para la comunicación entre security groups

# Cluster -> Nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.cluster.id
  description             = "Allow all traffic from cluster to nodes"
}

# Nodes -> Cluster
resource "aws_security_group_rule" "nodes_to_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.nodes.id
  description             = "Allow all traffic from nodes to cluster"
}

# ALB -> Nodes (NodePort)
resource "aws_security_group_rule" "alb_to_nodes_nodeport" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.alb.id
  description             = "Allow traffic from ALB to NodePort"
}

# Nodes -> Pods
resource "aws_security_group_rule" "nodes_to_pods" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.pods.id
  source_security_group_id = aws_security_group.nodes.id
  description             = "Allow all traffic from nodes to pods"
}

# Pods -> Nodes
resource "aws_security_group_rule" "pods_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.pods.id
  description             = "Allow all traffic from pods to nodes"
}

# VPC CIDR -> Nodes
resource "aws_security_group_rule" "vpc_to_nodes" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic from VPC CIDR"
}

# VPC CIDR -> Cluster
resource "aws_security_group_rule" "vpc_to_cluster" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic from VPC CIDR"
}

# VPC CIDR -> Pods
resource "aws_security_group_rule" "vpc_to_pods" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.pods.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic from VPC CIDR"
}

# Self-referential rules para cada security group
resource "aws_security_group_rule" "cluster_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  self              = true
  description       = "Allow traffic from the same security group"
}

resource "aws_security_group_rule" "nodes_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes.id
  self              = true
  description       = "Allow traffic from the same security group"
}

resource "aws_security_group_rule" "pods_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.pods.id
  self              = true
  description       = "Allow traffic from the same security group"
}

resource "aws_security_group_rule" "alb_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.alb.id
  self              = true
  description       = "Allow traffic from the same security group"
}