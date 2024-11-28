variable "enable_load_generator" {
  description = "Habilitar la construcción y despliegue del load generator"
  type        = bool
  default     = false
}

variable "services" {
  description = "Lista de servicios que necesitan repositorios ECR"
  type        = list(string)
  default = [
    "adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice"
  ]
}

# Variable local para manejar los servicios incluyendo loadgenerator condicionalmente
locals {
  all_services = var.enable_load_generator ? concat(var.services, ["loadgenerator"]) : var.services
  # Mapa de rutas especiales para Dockerfiles
  dockerfile_paths = {
    "cartservice" = "src"  # Para cartservice, el Dockerfile está en src/
    default       = ""     # Para los demás servicios, está en la raíz
  }
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}