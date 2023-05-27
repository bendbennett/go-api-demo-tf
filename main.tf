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