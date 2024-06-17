locals {
  public_subnets_cidr = [ "10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26" ]
  private_subnets_cidr = [ "10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26" ]
  availability_zones = var.availability_zones
}
/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    var.common_tags,
    {
      "Name" = "Backend VPC"
    }
  )
}

/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    {
      "Name" = "Backend VPC Internet Gateway"
    }
  )
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.public_subnets_cidr)
  cidr_block              = element(local.public_subnets_cidr,   count.index)
  availability_zone       = element(local.availability_zones,   count.index)
  map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${element(local.availability_zones, count.index)}-public-subnet"
      Environment = var.environment
  })
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.private_subnets_cidr)
  cidr_block              = element(local.private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones,   count.index)
  map_public_ip_on_launch = false
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${element(local.availability_zones, count.index)}-private-subnet"
      Environment = var.environment
    }
  )
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-private-route-table"
      Environment = var.environment
    }
  )
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-public-route-table"
      Environment = var.environment
    }
  )
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [ aws_route_table.private.id ]
  vpc_endpoint_type = "Gateway"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-s3-gateway-endpoint"
      Environment = var.environment
    }
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids   = [ aws_route_table.private.id ]
  vpc_endpoint_type = "Gateway"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-dynamodb-gateway-endpoint"
      Environment = var.environment
    }
  )
}