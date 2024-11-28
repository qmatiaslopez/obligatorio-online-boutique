output "repository_urls" {
  description = "URLs de los repositorios ECR por servicio"
  value = {
    for k, v in aws_ecr_repository.services : k => v.repository_url
  }
}

output "repository_arns" {
  description = "ARNs de los repositorios ECR por servicio"
  value = {
    for k, v in aws_ecr_repository.services : k => v.arn
  }
}

output "image_push_complete" {
  description = "Mapa indicando el estado de finalización de los envíos de imágenes"
  value = {
    for k, v in null_resource.build_and_push : k => v.id
  }
}

output "image_pushes" {
  description = "Recursos nulos de envío de imágenes"
  value = null_resource.build_and_push
}