variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID del security group del ALB"
  type        = string
}