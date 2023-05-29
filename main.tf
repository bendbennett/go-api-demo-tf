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
  subnets = module.subnet-public.subnet_ids
}

module "security-group-ec2-instance" {
  source = "git::https://github.com/bendbennett/aws-security-group"

  security_group_rules_source_security_group_id = var.security_group_rules_source_security_group_id_ec2_instance_web
  source_security_group_ids = [module.security-group-load-balancer.security_group_id]
  security_group_rules_cidr_blocks = var.security_group_rules_cidr_blocks_ec2_instance_web
  vpc_id = module.vpc.vpc_id
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

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

data "template_file" "launch_configuration_web_user_data" {
  template = file("templates/web_user_data.sh")

  vars = {
    cluster_id = aws_ecs_cluster.ecs_cluster.id
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  image_id = var.launch_configuration_image_id
  instance_type = var.launch_configuration_instance_type
}
