resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = "${var.project_name}-vpc-${var.environment}"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-igw-${var.environment}"
    },
    var.tags
  )
}

# Subnets Públicas
resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.project_name}-public-${var.azs[count.index]}"
      "kubernetes.io/role/elb" = "1"
    },
    var.tags
  )
}

# Subnets Privadas
resource "aws_subnet" "private" {
  count = length(var.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + length(var.azs))
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      Name = "${var.project_name}-private-${var.azs[count.index]}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.tags
  )
}

# NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_failover ? 2 : 1
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.project_name}-nat-eip-${var.environment}-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_failover ? 2 : 1

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.project_name}-nat-${var.environment}-${count.index + 1}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name = "${var.project_name}-public-rt-${var.environment}"
    },
    var.tags
  )
}

# Route Tables privadas (una por AZ cuando hay failover)
resource "aws_route_table" "private" {
  count  = var.enable_nat_failover ? length(var.azs) : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.enable_nat_failover ? aws_nat_gateway.main[count.index].id : aws_nat_gateway.main[0].id
  }

  tags = merge(
    {
      Name = "${var.project_name}-private-rt-${var.environment}${var.enable_nat_failover ? "-${count.index + 1}" : ""}"
    },
    var.tags
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_failover ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}
