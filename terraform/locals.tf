locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
  }
  
  vpc_cidr = "10.0.0.0/16"
  azs      = ["${var.region}a", "${var.region}b"]
}
