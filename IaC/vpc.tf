data "aws_availability_zones" "az" {
  state = "available"
}
resource "aws_vpc" "main" {
  cidr_block            = var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_support    = "true"
  enable_dns_hostnames  = "true"

  tags                  = {
    Name                = "${var.project}-vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.main.id

  tags      = {
    Name    = "${var.project}-igw"
  }
}
resource "aws_subnet" "public1" {
  vpc_id                            = aws_vpc.main.id
  cidr_block                        = cidrsubnet(var.vpc_cidr,var.subnetcidr,0)
  availability_zone                 = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch           = true 
  tags                              = {
    Name                            = "${var.project}-public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id                            = aws_vpc.main.id
  cidr_block                        = cidrsubnet(var.vpc_cidr,var.subnetcidr,1)
  availability_zone                 = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch           = true 
  tags                              = {
    Name                            = "${var.project}-public2"
  }
}
resource "aws_route_table" "route-public" {
  vpc_id            = aws_vpc.main.id
  route {
      cidr_block    = "0.0.0.0/0"
      gateway_id    = aws_internet_gateway.igw.id
  }
  tags = {
      Name          = "${var.project}-public"
  }
  }
  resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route-public.id
}

  resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route-public.id
}
