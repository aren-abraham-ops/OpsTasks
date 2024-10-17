# provider "aws" {
#   region = var.aws_region
# }
# terraform {
#   backend "s3" {}
# }
# resource "aws_vpc" "ops" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#   tags = {
#     Name = "${var.environment}-vpc"
#   }
# }

# resource "aws_subnet" "public" {
#   count                   = var.public_subnet_count
#   vpc_id                  = aws_vpc.ops.id
#   cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index)
#   map_public_ip_on_launch = true
#   availability_zone       = element(var.availability_zones, count.index)
#   tags = {
#     Name = "${var.environment}-public-subnet-${count.index + 1}"
#   }
# }

# resource "aws_subnet" "private" {
#   count             = var.private_subnet_count
#   vpc_id            = aws_vpc.ops.id
#   cidr_block        = cidrsubnet(var.vpc_cidr, 3, var.public_subnet_count + count.index)
#   availability_zone = element(var.availability_zones, count.index)
#   tags = {
#     Name = "${var.environment}-private-subnet-${count.index + 1}"
#   }
# }

# resource "aws_internet_gateway" "ops" {
#   vpc_id = aws_vpc.ops.id
#   tags = {
#     Name = "${var.environment}-igw"
#   }
# }

# resource "aws_eip" "nat" {
#   vpc = true
#   tags = {
#     Name = "${var.environment}-nat-eip"
#   }
# }

# resource "aws_nat_gateway" "ops" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id
#   tags = {
#     Name = "${var.environment}-nat-gateway"
#   }
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.ops.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.ops.id
#   }
#   tags = {
#     Name = "${var.environment}-public-rt"
#   }
# }

# resource "aws_route_table_association" "public" {
#   count          = var.public_subnet_count
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.ops.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.ops.id
#   }
#   tags = {
#     Name = "${var.environment}-private-rt"
#   }
# }

# resource "aws_route_table_association" "private" {
#   count          = var.private_subnet_count
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }
