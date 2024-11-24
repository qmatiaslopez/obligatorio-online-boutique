provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.credenciales]    #Se pasa la clave por variable
}

