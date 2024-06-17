
resource "aws_vpc_endpoint" "vpc_endpoint_interface" {
  for_each = var.endpoints
  vpc_id       = var.vpc_id
  service_name = "${each.value}.${each.key}"

  vpc_endpoint_type = "Interface"

  security_group_ids = var.security_group_ids
  subnet_ids = var.subnet_ids
  # this must be set for fargate to work correctly
  private_dns_enabled = true

  tags = merge(
  var.common_tags,
  {
    Name       = "backend - Specific vpce for ${each.key}"
  },
  )
}