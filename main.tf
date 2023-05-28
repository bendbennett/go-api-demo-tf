resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public" {
  count = length(var.subnet_cidr_blocks_public)

  availability_zone = element(var.availability_zones, count.index)
  cidr_block = element(var.subnet_cidr_blocks_public, count.index)
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  count = length(var.subnet_cidr_blocks_public)

  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_public" {
  count = length(var.subnet_cidr_blocks_public)

  route_table_id = element(aws_route_table.route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "route_table_association" {
  count = length(var.subnet_cidr_blocks_public)

  route_table_id = element(aws_route_table.route_table.*.id, count.index)
  subnet_id = element(aws_subnet.subnet_public.*.id, count.index)
}

resource "aws_eip" "eip" {
  count = length(var.subnet_cidr_blocks_public)
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.subnet_cidr_blocks_public)

  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id = element(aws_subnet.subnet_public.*.id, count.index)
}

module "subnet-private" {
  source = "git::https://github.com/bendbennett/aws-subnet"

  availability_zones = var.availability_zones
  cidr_blocks = var.subnet_cidr_blocks_private
  nat_gateway_ids = aws_nat_gateway.nat_gateway.*.id
  public_subnet = false
  vpc_id = aws_vpc.vpc.id
}

module "security-group-load-balancer" {
  source = "git::https://github.com/bendbennett/aws-security-group"

  security_group_rules_cidr_blocks = var.security_group_rules_cidr_blocks_load_balancer_web
  vpc_id = aws_vpc.vpc.id
}

resource "aws_elb" "load_balancer" {
  listener {
    instance_port = 3000
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  listener {
    instance_port = 3000
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = var.ssl_certificate_id
  }
  cross_zone_load_balancing = var.load_balancer_cross_zone_load_balancing
  name = var.load_balancer_name
  security_groups = [module.security-group-load-balancer.security_group_id]
  subnets = aws_subnet.subnet_public.*.id
}

module "security-group-ec2-instance" {
  source = "git::https://github.com/bendbennett/aws-security-group"

  security_group_rules_source_security_group_id = var.security_group_rules_source_security_group_id_ec2_instance_web
  source_security_group_ids = [module.security-group-load-balancer.security_group_id]
  security_group_rules_cidr_blocks = var.security_group_rules_cidr_blocks_ec2_instance_web
  vpc_id = aws_vpc.vpc.id
}

data "aws_iam_policy_document" "iam_policy_document_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = var.launch_configuration_role_policy_identifiers
    }
  }
}

resource "aws_iam_role_policy" "iam_role_policy" {
  policy = var.launch_configuration_policy_actions_resources
  role = aws_iam_role.iam_role.id
}

resource "aws_iam_role" "iam_role" {
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document_role_policy.json
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  role = aws_iam_role.iam_role.name
}
