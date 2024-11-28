variable "project_name" {
  description = "Nombre del proyecto"
  type = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type = string
}

variable "cluster_version" {
  description = "Versión de Kubernetes"
  type = string
  default = "1.31"
}

variable "vpc_id" {
  description = "ID de la VPC"
  type = string
}

variable "private_subnets" {
  description = "IDs de las subnets privadas"
  type = list(string)
}

variable "public_subnets" {
  description = "IDs de las subnets públicas"
  type = list(string)
}

variable "cluster_role_arn" {
  description = "ARN del rol del cluster"
  type = string
}

variable "nodes_role_arn" {
  description = "ARN del rol de los nodos"
  type = string
}

variable "cluster_sg_id" {
  description = "ID del security group del cluster"
  type = string
}

variable "nodes_sg_id" {
  description = "ID del security group de los nodos"
  type = string
}

variable "tags" {
  description = "Tags para los recursos"
  type = map(string)
  default = {}
}