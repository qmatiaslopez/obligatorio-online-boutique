# Target Group para el frontend
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend"
  port        = 30080  # Match the NodePort
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    path               = "/_healthz"
    port               = "30080"  # Match the NodePort
    protocol           = "HTTP"
    timeout            = 10
    unhealthy_threshold = 3
  }

  tags = merge(
    {
      Name = "${var.project_name}-frontend-tg"
    },
    var.tags
  )
}

# Application Load Balancer
resource "aws_lb" "frontend" {
  name               = "${var.project_name}-frontend"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets           = var.public_subnets
  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      Name = "${var.project_name}-frontend-alb"
    },
    var.tags
  )
}

# Listener para el ALB
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Auto Scaling Group Target Attachment
resource "aws_autoscaling_attachment" "frontend" {
  autoscaling_group_name = var.eks_asg_name
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}