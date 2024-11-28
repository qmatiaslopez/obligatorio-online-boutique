resource "aws_ecr_repository" "services" {
  for_each = toset(local.all_services)

  name                 = "${var.project_name}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "null_resource" "build_and_push" {
  for_each = aws_ecr_repository.services

  triggers = {
    repository_url = each.value.repository_url
    dockerfile_hash = fileexists(
      "${path.root}/../online-boutique/src/${each.key}/${lookup(local.dockerfile_paths, each.key, local.dockerfile_paths["default"])}/Dockerfile"
    ) ? filesha256(
      "${path.root}/../online-boutique/src/${each.key}/${lookup(local.dockerfile_paths, each.key, local.dockerfile_paths["default"])}/Dockerfile"
    ) : "no-dockerfile"
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Login a ECR
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
      
      # Construir y subir imagen
      cd ${path.root}/../online-boutique/src/${each.key}/${lookup(local.dockerfile_paths, each.key, local.dockerfile_paths["default"])}
      docker build -t ${each.value.repository_url}:latest .
      docker push ${each.value.repository_url}:latest
    EOT
  }
}