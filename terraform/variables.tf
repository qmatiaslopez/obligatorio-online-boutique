variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "online-boutique"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "production"
}

variable "app_namespace" {
  description = "Namespace para la aplicación"
  type        = string
  default     = "online-boutique"
}

variable "cluster_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.31"
}

variable "enable_load_generator" {
  description = "Habilitar la construcción y despliegue del load generator"
  type        = bool
  default     = false
}