variable "region" { # Definicion de variable para definir region
  type    = string
  default = "us-east-1"
}

variable "availability_zone1" { # Definicion de variable para definir AZ
  type    = string
  default = "us-east-1a"
}

variable "availability_zone2" { # Definicion de variable para definir AZ
  type    = string
  default = "us-east-1b"
}

variable "cidr_block_VPC" { # Definicion de variable para CIDR_Block - se va a utilizar en el VPC
  type    = string
  default = "172.16.0.0/16"
}

variable "cidr_block_subnet1" { # Definicion de variable para CIDR_Block - se va a utilizar en la SubNet
  type    = string
  default = "172.16.1.0/24"
}

variable "cidr_block_subnet2" { # Definicion de variable para CIDR_Block - se va a utilizar en la SubNet
  type    = string
  default = "172.16.2.0/24"
}

variable "credenciales" {     # Se debe pasar la ruta al archivo donde se almacena la clave
    type = string
}
