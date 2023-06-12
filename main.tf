### VPC ###
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

### PUBLIC SUBNET ###
resource "aws_subnet" "subnet_public" {
  count = length(var.subnet_public_cidr_blocks)

  availability_zone = element(var.availability_zones, count.index)
  cidr_block        = element(var.subnet_public_cidr_blocks, count.index)
  vpc_id            = aws_vpc.vpc.id
}

### PUBLIC SUBNET - ROUTES ###
resource "aws_route_table" "route_table_public" {
  count = length(var.subnet_public_cidr_blocks)

  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_public" {
  count = length(var.subnet_public_cidr_blocks)

  route_table_id         = element(aws_route_table.route_table_public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "route_table_association_public" {
  count = length(var.subnet_public_cidr_blocks)

  route_table_id = element(aws_route_table.route_table_public.*.id, count.index)
  subnet_id      = element(aws_subnet.subnet_public.*.id, count.index)
}

### PUBLIC SUBNET - NAT GATEWAYS ###
resource "aws_eip" "eip" {
  count = length(var.subnet_public_cidr_blocks)
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.subnet_public_cidr_blocks)

  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(aws_subnet.subnet_public.*.id, count.index)
}

### PRIVATE SUBNET ###
resource "aws_subnet" "subnet_private" {
  count = length(var.subnet_private_cidr_blocks)

  availability_zone = element(var.availability_zones, count.index)
  cidr_block        = element(var.subnet_private_cidr_blocks, count.index)
  vpc_id            = aws_vpc.vpc.id
}

### PRIVATE SUBNET - ROUTES ###
resource "aws_route_table" "route_table_private" {
  count = length(var.subnet_private_cidr_blocks)

  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_private" {
  count = length(var.subnet_private_cidr_blocks)

  route_table_id         = element(aws_route_table.route_table_private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)
}

resource "aws_route_table_association" "route_table_association" {
  count = length(var.subnet_private_cidr_blocks)

  route_table_id = element(aws_route_table.route_table_private.*.id, count.index)
  subnet_id      = element(aws_subnet.subnet_private.*.id, count.index)
}

### LOAD BALANCER ###
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "load_balancer_security_group_rule_cidr_blocks" {
  count = length(var.load_balancer_security_group_rules_cidr_blocks)

  cidr_blocks       = [lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "cidr_blocks")]
  from_port         = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "from_port")
  protocol          = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "protocol")
  security_group_id = aws_security_group.load_balancer_security_group.id
  to_port           = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "to_port")
  type              = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "type")
}

resource "aws_lb_target_group" "target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    healthy_threshold = 2
    interval          = 30
    matcher           = "200"
    path              = "/"
    port              = 80
    protocol          = "HTTP"
    timeout           = 3
  }
}

resource "aws_lb_target_group" "target_group_grpc" {
  port             = 50051
  protocol         = "HTTP"
  protocol_version = "GRPC"
  vpc_id           = aws_vpc.vpc.id

  health_check {
    healthy_threshold = 2
    interval          = 30
    matcher           = "0-99"
    port              = 50051
    protocol          = "HTTP"
    timeout           = 3
  }
}

resource "aws_lb" "load_balancer" {
  name               = var.load_balancer_name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = aws_subnet.subnet_public.*.id
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_listener" "load_balancer_listener_https" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_listener" "load_balancer_listener_grpc" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 50051
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_grpc.arn
  }
}

### EC2 INSTANCES ###
resource "aws_security_group" "ec2_security_group" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "security_group_rule_cidr_blocks" {
  count = length(var.security_group_rules_cidr_blocks_ec2_instance_web)

  cidr_blocks = [lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "cidr_blocks")]
  from_port = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "from_port")
  protocol = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "protocol")
  security_group_id = aws_security_group.ec2_security_group.id
  to_port = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "to_port")
  type = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "type")
}

resource "aws_security_group_rule" "security_group_rule_source_security_group_id" {
  count = length(var.security_group_rules_source_security_group_id_ec2_instance_web)

  from_port = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "from_port")
  protocol = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "protocol")
  security_group_id = aws_security_group.ec2_security_group.id
  source_security_group_id = [aws_security_group.load_balancer_security_group.id][count.index]
  to_port = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "to_port")
  type = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "type")
}

data "aws_iam_policy_document" "ec2_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_role.json
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "iam_role_policy" {
  policy = var.launch_configuration_policy_actions_resources
  role   = aws_iam_role.ec2_role.id
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  role = aws_iam_role.ec2_role.name
}

### LOG ###
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

### ECS ###
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

data "template_file" "launch_configuration_web_user_data" {
  template = file("templates/web_user_data.sh")

  vars = {
    cluster_id = aws_ecs_cluster.ecs_cluster.id
  }
}

//TODO: Replace with launch templates
resource "aws_launch_configuration" "launch_configuration" {
  associate_public_ip_address = var.launch_configuration_associate_public_ip_address
  iam_instance_profile        = aws_iam_instance_profile.iam_instance_profile.id
  image_id                    = var.launch_configuration_image_id
  instance_type               = var.launch_configuration_instance_type
  key_name                    = var.launch_configuration_key_name
  security_groups             = [
    aws_security_group.ec2_security_group.id,
  ]
  user_data = data.template_file.launch_configuration_web_user_data.rendered
}

resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity          = var.autoscaling_group_desired_capacity
  health_check_type         = var.autoscaling_group_health_check_type
  health_check_grace_period = 60
  launch_configuration      = aws_launch_configuration.launch_configuration.name
  max_size                  = var.autoscaling_group_max_size
  min_size                  = var.autoscaling_group_min_size
  vpc_zone_identifier       = aws_subnet.subnet_private.*.id
}

data "template_file" "task_definition_web_container_definitions" {
  template = file("templates/web_task_definition_container_definitions.json")
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  container_definitions = data.template_file.task_definition_web_container_definitions.rendered
  family                = var.ecs_task_definition_family
}

data "aws_iam_policy_document" "ecs_iam_policy_document_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = var.ecs_role_policy_identifiers
    }
  }
}

resource "aws_iam_role_policy" "ecs_iam_role_policy" {
  policy = var.ecs_policy_actions_resources
  role   = aws_iam_role.ecs_iam_role.id
}

resource "aws_iam_role" "ecs_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_iam_policy_document_role_policy.json
}

resource "aws_ecs_service" "ecs_service" {
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent
  desired_count                      = var.ecs_service_desired_count
  #  iam_role                           = aws_iam_role.ecs_iam_role.id
  name                               = var.ecs_service_name
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn

  load_balancer {
    container_name   = var.ecs_service_container_name
    container_port   = var.ecs_service_container_port
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  load_balancer {
    container_name   = var.ecs_service_container_name
    container_port   = var.ecs_service_container_grpc_port
    target_group_arn = aws_lb_target_group.target_group_grpc.arn
  }
}

resource "aws_route53_record" "route53_record" {
  name    = var.route53_record_name
  records = [aws_lb.load_balancer.dns_name]
  ttl     = "60"
  type    = "CNAME"
  zone_id = var.route53_record_zone_id
}

### SESSION MANAGER ###
resource "aws_security_group" "session_manager" {
  vpc_id = aws_vpc.vpc.id
  name   = "security-group-session-manager"

  ingress {
    cidr_blocks = var.subnet_private_cidr_blocks
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  tags = {
    Name = "session-manager"
  }
}

resource "aws_vpc_endpoint" "session_manager_ec2_messages" {
  service_name       = "com.amazonaws.eu-west-2.ec2messages"
  security_group_ids = [
    aws_security_group.session_manager.id
  ]
  subnet_ids        = aws_subnet.subnet_private.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "session_manager_ssm" {
  service_name       = "com.amazonaws.eu-west-2.ssm"
  security_group_ids = [
    aws_security_group.session_manager.id
  ]
  subnet_ids        = aws_subnet.subnet_private.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "session_manager_ssm_messages" {
  service_name       = "com.amazonaws.eu-west-2.ssmmessages"
  security_group_ids = [
    aws_security_group.session_manager.id
  ]
  subnet_ids        = aws_subnet.subnet_private.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}
