module "vpc" {
  source = "git::https://github.com/bendbennett/aws-vpc"

  cidr_block = var.vpc_cidr_block
}

module "subnet-public" {
  source = "git::https://github.com/bendbennett/aws-subnet"

  availability_zones = var.availability_zones
  cidr_blocks = var.subnet_cidr_blocks_public
  internet_gateway_id = module.vpc.internet_gateway_id
  public_subnet = true
  vpc_id = module.vpc.vpc_id
}

module "subnet-private" {
  source = "git::https://github.com/bendbennett/aws-subnet"

  availability_zones = var.availability_zones
  cidr_blocks = var.subnet_cidr_blocks_private
  nat_gateway_ids = module.subnet-public.nat_gateway_ids
  public_subnet = false
  vpc_id = module.vpc.vpc_id
}

module "security-group-load-balancer" {
  source = "git::https://github.com/bendbennett/aws-security-group"

  security_group_rules_cidr_blocks = var.security_group_rules_cidr_blocks_load_balancer_web
  vpc_id = module.vpc.vpc_id
}

resource "aws_elb" "load_balancer" {
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = var.ssl_certificate_id
  }
  cross_zone_load_balancing = var.load_balancer_cross_zone_load_balancing
  name = var.load_balancer_name
  security_groups = [module.security-group-load-balancer.security_group_id]
  subnets = module.subnet-public.subnet_ids
}