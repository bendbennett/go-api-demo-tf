module "vpc" {
  source = "git::https://github.com/bendbennett/aws-vpc"

  cidr_block = var.vpc_cidr_block
}

module "subnet-public" {
  source = "git::https://github.com/bendbennett/aws-subnet"

  availability_zones = var.availability_zones
  cidr_blocks = var.subnet_cidr_blocks_public
  vpc_id = module.vpc.vpc_id
}
