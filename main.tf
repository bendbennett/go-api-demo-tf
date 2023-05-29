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
  associate_public_ip_address = var.launch_configuration_associate_public_ip_address
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  image_id = var.launch_configuration_image_id
  instance_type = var.launch_configuration_instance_type
  key_name = var.launch_configuration_key_name
  security_groups = [module.security-group-ec2-instance.security_group_id]
  user_data = data.template_file.launch_configuration_web_user_data.rendered
}

resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity = var.autoscaling_group_desired_capacity
  health_check_type = var.autoscaling_group_health_check_type
  launch_configuration = aws_launch_configuration.launch_configuration.name
  max_size = var.autoscaling_group_max_size
  min_size = var.autoscaling_group_min_size
  vpc_zone_identifier = module.subnet-public.subnet_ids
}

data "template_file" "task_definition_web_container_definitions" {
  template = file("templates/web_task_definition_container_definitions.json")
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  container_definitions = data.template_file.task_definition_web_container_definitions.rendered
  family = var.ecs_task_definition_family
}

data "aws_iam_policy_document" "ecs_iam_policy_document_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = var.ecs_role_policy_identifiers
    }
  }
}

resource "aws_iam_role_policy" "ecs_iam_role_policy" {
  policy = var.ecs_policy_actions_resources
  role = aws_iam_role.ecs_iam_role.id
}

resource "aws_iam_role" "ecs_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_iam_policy_document_role_policy.json
}

resource "aws_ecs_service" "ecs_service" {
  cluster = aws_ecs_cluster.ecs_cluster.id
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent
  desired_count = var.ecs_service_desired_count
  iam_role = aws_iam_role.ecs_iam_role.id
  name = var.ecs_service_name
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn

  load_balancer {
    elb_name       = aws_elb.load_balancer.name
    container_name = var.ecs_service_container_name
    container_port = var.ecs_service_container_port
  }
}
