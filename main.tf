module "vpc" {
  source = "git::https://github.com/bendbennett/aws-vpc"

  cidr_block = var.cidr_block
  region = var.region
}
