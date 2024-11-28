variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "public_subnets" {
  description = "IDs de las subnets públicas"
  type        = list(string)
}

variable "eks_asg_name" {
  description = "Nombre del Auto Scaling Group de EKS"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID del security group para el ALB"
  type        = string
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}