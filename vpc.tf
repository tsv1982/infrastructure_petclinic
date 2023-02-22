resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private_subnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name        = "${var.app_name}-private_subnet"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "public_subnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name        = "${var.app_name}-public_subnet"
    Environment = var.app_environment
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id           = aws_vpc.vpc.id
  tags = {
    Name        = "${var.app_name}-internet_gateway"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "route_table" {
  vpc_id       = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name        = "${var.app_name}-route_table"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "route_table" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table" "instance" {
  vpc_id           = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "instance" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.instance.id
}

resource "aws_eip" "eip_nat_gateway" {  
  vpc = true
}

resource "aws_eip" "eip_bastion" {
  instance = aws_instance.bastion_instance.id
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_nat_gateway.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name        = "${var.app_name}-nat_gateway"
    Environment = var.app_environment
  }
}
