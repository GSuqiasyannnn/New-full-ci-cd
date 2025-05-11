locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "CI-CD-vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "CI-CD-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "CI-CD_igw" {
  vpc_id = aws_vpc.CI-CD-vpc.id

  tags = {
    Name = "CI-CD_igw"
  }
}

# Public Route Table
resource "aws_route_table" "CI-CD_public_rt" {
  vpc_id = aws_vpc.CI-CD-vpc.id

  tags = {
    Name = "CI-CD_public_rt"
  }
}

# Route to Internet in Public Route Table
resource "aws_route" "CI-CD_public_internet_access" {
  route_table_id         = aws_route_table.CI-CD_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.CI-CD_igw.id
}

# Public Subnets
resource "aws_subnet" "CI-CD_pub_sub" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.CI-CD-vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "CI-CD_pub_sub-${count.index + 1}"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "CI-CD_public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.CI-CD_pub_sub[count.index].id
  route_table_id = aws_route_table.CI-CD_public_rt.id
}

# Private Subnets
resource "aws_subnet" "CI-CD_priv_sub" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.CI-CD-vpc.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "CI-CD_priv_sub-${count.index + 1}"
  }
}

# Optional: Use default route table as "private" route table
resource "aws_default_route_table" "CI-CD_private_rt" {
  default_route_table_id = aws_vpc.CI-CD-vpc.default_route_table_id

  tags = {
    Name = "CI-CD_private_rt"
  }
}

resource "aws_security_group" "CI-CD_sg" {
  name        = "CI-CD_sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.CI-CD-vpc.id

  tags = {
    Name = "CI-CD_sg"
  }
}

resource "aws_security_group_rule" "CI-CD_ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.CI-CD_sg.id
}

resource "aws_security_group_rule" "CI-CD_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.CI-CD_sg.id
}

