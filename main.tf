provider "aws" {
  region = var.aws_region
}

# Generate a random ID to ensure unique VPC creation
resource "random_id" "vpc" {
  byte_length = 2
}
resource "time_static" "current" {}

# Create a new VPC with a unique CIDR block and name
resource "aws_vpc" "main" {
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, random_id.vpc.dec % 256) # Ensure unique /24 CIDR within /16
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }

}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index) # Create /28 subnets within the VPC
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }

}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 3) # Create /28 subnets for private
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index}-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }


}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }


}

# Create Public Route Table for the VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }

  tags = {
    Name = "public-route-table-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }


}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }


}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
