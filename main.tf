### VPC ###
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

#resource "aws_internet_gateway" "internet_gateway" {
#  vpc_id = aws_vpc.vpc.id
#}
#
#### PUBLIC SUBNET ###
#resource "aws_subnet" "public" {
#  count = length(var.subnet_public_cidr_blocks)
#
#  availability_zone = element(var.availability_zones, count.index)
#  cidr_block        = element(var.subnet_public_cidr_blocks, count.index)
#  vpc_id            = aws_vpc.vpc.id
#}
#
#resource "aws_route_table" "public" {
#  count = length(var.subnet_public_cidr_blocks)
#
#  vpc_id = aws_vpc.vpc.id
#}
#
#resource "aws_route" "public" {
#  count = length(var.subnet_public_cidr_blocks)
#
#  route_table_id         = element(aws_route_table.public.*.id, count.index)
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = aws_internet_gateway.internet_gateway.id
#}
#
#resource "aws_route_table_association" "public" {
#  count = length(var.subnet_public_cidr_blocks)
#
#  route_table_id = element(aws_route_table.public.*.id, count.index)
#  subnet_id      = element(aws_subnet.public.*.id, count.index)
#}
#
#resource "aws_eip" "eip" {
#  count = length(var.subnet_public_cidr_blocks)
#}
#
#resource "aws_nat_gateway" "nat_gateway" {
#  count = length(var.subnet_public_cidr_blocks)
#
#  allocation_id = element(aws_eip.eip.*.id, count.index)
#  subnet_id     = element(aws_subnet.public.*.id, count.index)
#}
#
#### PRIVATE SUBNET ###
#resource "aws_subnet" "private" {
#  count = length(var.subnet_private_cidr_blocks)
#
#  availability_zone = element(var.availability_zones, count.index)
#  cidr_block        = element(var.subnet_private_cidr_blocks, count.index)
#  vpc_id            = aws_vpc.vpc.id
#}
#
#resource "aws_route_table" "private" {
#  count = length(var.subnet_private_cidr_blocks)
#
#  vpc_id = aws_vpc.vpc.id
#}
#
#resource "aws_route" "private" {
#  count = length(var.subnet_private_cidr_blocks)
#
#  route_table_id         = element(aws_route_table.private.*.id, count.index)
#  destination_cidr_block = "0.0.0.0/0"
#  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)
#}
#
#resource "aws_route_table_association" "private" {
#  count = length(var.subnet_private_cidr_blocks)
#
#  route_table_id = element(aws_route_table.private.*.id, count.index)
#  subnet_id      = element(aws_subnet.private.*.id, count.index)
#}
#
#### LOAD BALANCER ###
#resource "aws_security_group" "load_balancer" {
#  vpc_id = aws_vpc.vpc.id
#}
#
#resource "aws_security_group_rule" "load_balancer" {
#  count = length(var.load_balancer_security_group_rules_cidr_blocks)
#
#  cidr_blocks       = [lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "cidr_blocks")]
#  from_port         = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "from_port")
#  protocol          = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "protocol")
#  security_group_id = aws_security_group.load_balancer.id
#  to_port           = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "to_port")
#  type              = lookup(var.load_balancer_security_group_rules_cidr_blocks[count.index], "type")
#}
#
#resource "aws_lb_target_group" "http" {
#  port     = 80
#  protocol = "HTTP"
#  vpc_id   = aws_vpc.vpc.id
#
#  health_check {
#    healthy_threshold = 2
#    interval          = 30
#    matcher           = "200"
#    path              = "/"
#    port              = 80
#    protocol          = "HTTP"
#    timeout           = 3
#  }
#}
#
#resource "aws_lb_target_group" "grpc" {
#  port             = 50051
#  protocol         = "HTTP"
#  protocol_version = "GRPC"
#  vpc_id           = aws_vpc.vpc.id
#
#  health_check {
#    healthy_threshold = 2
#    interval          = 30
#    matcher           = "0-99"
#    port              = 50051
#    protocol          = "HTTP"
#    timeout           = 3
#  }
#}
#
#resource "aws_lb" "go-api-demo" {
#  name               = var.load_balancer_name
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.load_balancer.id]
#  subnets            = aws_subnet.public.*.id
#}
#
#resource "aws_lb_listener" "http" {
#  load_balancer_arn = aws_lb.go-api-demo.arn
#  port              = 80
#  protocol          = "HTTP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.http.arn
#  }
#}
#
#resource "aws_lb_listener" "https" {
#  load_balancer_arn = aws_lb.go-api-demo.arn
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = var.certificate_arn
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.http.arn
#  }
#}
#
#resource "aws_lb_listener" "grpc" {
#  load_balancer_arn = aws_lb.go-api-demo.arn
#  port              = 50051
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = var.certificate_arn
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.grpc.arn
#  }
#}
#
#### EC2, LAUNCH TEMPLATE & AUTOSCALING GROUP ###
#resource "aws_security_group" "ec2" {
#  vpc_id = aws_vpc.vpc.id
#}
#
#resource "aws_security_group_rule" "ec2_cidr_blocks" {
#  count = length(var.security_group_rules_cidr_blocks_ec2_instance_web)
#
#  cidr_blocks       = [lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "cidr_blocks")]
#  from_port         = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "from_port")
#  protocol          = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "protocol")
#  security_group_id = aws_security_group.ec2.id
#  to_port           = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "to_port")
#  type              = lookup(var.security_group_rules_cidr_blocks_ec2_instance_web[count.index], "type")
#}
#
#resource "aws_security_group_rule" "ec2_source_security_group_id" {
#  count = length(var.security_group_rules_source_security_group_id_ec2_instance_web)
#
#  from_port                = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "from_port")
#  protocol                 = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "protocol")
#  security_group_id        = aws_security_group.ec2.id
#  source_security_group_id = aws_security_group.load_balancer.id
#  to_port                  = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "to_port")
#  type                     = lookup(var.security_group_rules_source_security_group_id_ec2_instance_web[count.index], "type")
#}
#
#data "aws_iam_policy_document" "ec2" {
#  statement {
#    actions = ["sts:AssumeRole"]
#    effect  = "Allow"
#
#    principals {
#      type        = "Service"
#      identifiers = [
#        "ec2.amazonaws.com",
#        "ssm.amazonaws.com"
#      ]
#    }
#  }
#}
#
#resource "aws_iam_role" "ec2" {
#  name               = "ec2_role"
#  assume_role_policy = data.aws_iam_policy_document.ec2.json
#}
#
#resource "aws_iam_role_policy_attachment" "ssm" {
#  role       = aws_iam_role.ec2.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#}
#
#resource "aws_iam_role_policy" "ec2" {
#  policy = file("templates/ec2_policy.json")
#  role   = aws_iam_role.ec2.id
#}
#
#resource "aws_iam_instance_profile" "ec2" {
#  role = aws_iam_role.ec2.name
#}
#
#data "template_file" "ecs_docker_user_data" {
#  template = file("templates/ecs_docker_user_data.sh")
#
#  vars = {
#    cluster_id = aws_ecs_cluster.go_api_demo.id
#  }
#}
#
#data "aws_ami" "ecs_ami" {
#  most_recent = true
#  owners      = ["amazon"]
#
#  filter {
#    name   = "name"
#    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
#  }
#}
#
#resource "aws_launch_template" "go_api_demo" {
#  image_id               = data.aws_ami.ecs_ami.id
#  instance_type          = var.launch_template_instance_type
#  user_data              = base64encode(data.template_file.ecs_docker_user_data.rendered)
#  vpc_security_group_ids = [
#    aws_security_group.ec2.id,
#  ]
#
#  iam_instance_profile {
#    arn = aws_iam_instance_profile.ec2.arn
#  }
#}
#
#resource "aws_autoscaling_group" "go_api_demo" {
#  desired_capacity          = var.autoscaling_group_desired_capacity
#  health_check_type         = var.autoscaling_group_health_check_type
#  health_check_grace_period = 60
#  max_size            = var.autoscaling_group_max_size
#  min_size            = var.autoscaling_group_min_size
#  vpc_zone_identifier = aws_subnet.private.*.id
#
#  launch_template {
#    id      = aws_launch_template.go_api_demo.id
#    version = "$Latest"
#  }
#}
#
#### ECS ###
#resource "aws_ecs_cluster" "go_api_demo" {
#  name = var.ecs_cluster_name
#}
#
#data "template_file" "go_api_demo_task_definition" {
#  template = file("templates/go_api_demo_task_definition.json")
#}
#
#resource "aws_ecs_task_definition" "go_api_demo" {
#  container_definitions = data.template_file.go_api_demo_task_definition.rendered
#  family                = var.ecs_task_definition_family
#}
#
#resource "aws_ecs_service" "go_api_demo" {
#  cluster                            = aws_ecs_cluster.go_api_demo.id
#  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent
#  desired_count                      = var.ecs_service_desired_count
#  name                               = var.ecs_service_name
#  task_definition                    = aws_ecs_task_definition.go_api_demo.arn
#
#  load_balancer {
#    container_name   = var.ecs_service_container_name
#    container_port   = var.ecs_service_container_http_port
#    target_group_arn = aws_lb_target_group.http.arn
#  }
#
#  load_balancer {
#    container_name   = var.ecs_service_container_name
#    container_port   = var.ecs_service_container_grpc_port
#    target_group_arn = aws_lb_target_group.grpc.arn
#  }
#}
#
#### ROUTE 53 ###
#resource "aws_route53_record" "go_api_demo" {
#  name    = var.route53_record_name
#  records = [aws_lb.go-api-demo.dns_name]
#  ttl     = "60"
#  type    = "CNAME"
#  zone_id = var.route53_record_zone_id
#}
#
#### LOG ###
#resource "aws_cloudwatch_log_group" "logs" {
#  name              = var.cloudwatch_log_group_name
#  retention_in_days = var.cloudwatch_log_group_retention_in_days
#}
#
#### SESSION MANAGER ###
#resource "aws_security_group" "session_manager" {
#  vpc_id = aws_vpc.vpc.id
#  name   = "security-group-session-manager"
#
#  ingress {
#    cidr_blocks = var.subnet_private_cidr_blocks
#    from_port   = 443
#    protocol    = "tcp"
#    to_port     = 443
#  }
#
#  tags = {
#    Name = "session-manager"
#  }
#}
#
#resource "aws_vpc_endpoint" "session_manager_ec2_messages" {
#  service_name       = "com.amazonaws.eu-west-2.ec2messages"
#  security_group_ids = [
#    aws_security_group.session_manager.id
#  ]
#  subnet_ids        = aws_subnet.private.*.id
#  vpc_endpoint_type = "Interface"
#  vpc_id            = aws_vpc.vpc.id
#}
#
#resource "aws_vpc_endpoint" "session_manager_ssm" {
#  service_name       = "com.amazonaws.eu-west-2.ssm"
#  security_group_ids = [
#    aws_security_group.session_manager.id
#  ]
#  subnet_ids        = aws_subnet.private.*.id
#  vpc_endpoint_type = "Interface"
#  vpc_id            = aws_vpc.vpc.id
#}
#
#resource "aws_vpc_endpoint" "session_manager_ssm_messages" {
#  service_name       = "com.amazonaws.eu-west-2.ssmmessages"
#  security_group_ids = [
#    aws_security_group.session_manager.id
#  ]
#  subnet_ids        = aws_subnet.private.*.id
#  vpc_endpoint_type = "Interface"
#  vpc_id            = aws_vpc.vpc.id
#}
