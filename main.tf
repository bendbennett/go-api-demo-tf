module "vpc" {
  source = "git::https://github.com/bendbennett/aws-vpc"

  region = var.vpc_region

  cidr_block = var.vpc_cidr_block
}

module "subnet-public" {
  source = "git::https://github.com/bendbennett/aws-subnet"

  region = var.subnet_region

  availability_zones = var.subnet_availability_zones
  cidr_blocks = var.subnet_cidr_blocks_public
  vpc_id = module.vpc.vpc_id
}
