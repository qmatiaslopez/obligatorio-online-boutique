terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34"
    }
  }
}

provider "aws" {
  region = var.region
  # AWS automáticamente usará las credenciales del archivo ~/.aws/credentials
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}