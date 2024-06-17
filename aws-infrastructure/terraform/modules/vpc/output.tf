output "private_subnets_id" {
  description = "Private subnets IDs of the created VPC"
  value = [
    aws_subnet.private_subnet[0].id,
    aws_subnet.private_subnet[1].id,
    aws_subnet.private_subnet[2].id
  ]
}

output "public_subnets_id" {
  description = "Public subnets IDs of the created VPC"
  value = [
    aws_subnet.public_subnet[0].id,
    aws_subnet.public_subnet[1].id,
    aws_subnet.public_subnet[2].id
  ]
}

output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value = aws_vpc.vpc.cidr_block
}