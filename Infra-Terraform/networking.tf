resource "aws_vpc" "online-boutique-vpc" { # Creacion de VPC
  cidr_block = var.cidr_block_VPC
  tags = {
    Name = "online-boutique-vpc"
  }
}

resource "aws_subnet" "online-boutique-subnet-public1" { # Creacion de SubNet publica 1
  vpc_id                  = aws_vpc.online-boutique-vpc.id
  cidr_block              = var.cidr_block_subnet1
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone1

  tags = {
    Name = "online-boutique-subnet-public1"
  }
}

resource "aws_subnet" "online-boutique-subnet-public2" { # Creacion de SubNet publica 2
  vpc_id                  = aws_vpc.online-boutique-vpc.id
  cidr_block              = var.cidr_block_subnet2
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone2

  tags = {
    Name = "online-boutique-subnet-public2"
  }
}

resource "aws_internet_gateway" "online-boutique-ig" { # Creacion de Internet Gateway
  vpc_id = aws_vpc.online-boutique-vpc.id
  tags = {
    Name = "online-boutique-ig"
  }
}

resource "aws_route_table" "online-boutique-route-table" {
  vpc_id = aws_vpc.online-boutique-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.online-boutique-ig.id
  }

  tags = {
    Name = "online-boutique-route-table"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.online-boutique-subnet-public1.id
  route_table_id = aws_route_table.online-boutique-route-table.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.online-boutique-subnet-public2.id
  route_table_id = aws_route_table.online-boutique-route-table.id
}








