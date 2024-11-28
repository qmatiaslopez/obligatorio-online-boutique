module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = local.vpc_cidr
  azs          = local.azs
  tags         = local.tags
}

module "lb" {
  source = "./modules/lb"
  
  project_name        = var.project_name
  environment         = var.environment
  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnets
  eks_asg_name       = module.eks.node_group_asg_name
  alb_security_group_id = module.security.alb_security_group_id
  tags               = local.tags
  
  depends_on = [module.eks]
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = module.networking.vpc_cidr
  tags         = local.tags
  depends_on = [module.networking]
}

module "eks" {
  source = "./modules/eks"
  project_name = var.project_name
  environment = var.environment
  cluster_version = var.cluster_version
  vpc_id = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  public_subnets = module.networking.public_subnets
  cluster_role_arn = "arn:aws:iam::184699688245:role/LabRole"
  nodes_role_arn = "arn:aws:iam::184699688245:role/LabRole"
  cluster_sg_id = module.security.cluster_security_group_id
  nodes_sg_id = module.security.nodes_security_group_id
  tags = local.tags
  depends_on = [module.security]
}

module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
  tags         = local.tags
  enable_load_generator = var.enable_load_generator
  depends_on = [module.eks]  # Esperamos a que el cluster esté listo
}