variable "autoscaling_group_desired_capacity" {}

variable "autoscaling_group_health_check_type" {}

variable "autoscaling_group_max_size" {}

variable "autoscaling_group_min_size" {}

variable "availability_zones" {}

variable "certificate_arn" {}

variable "cloudwatch_log_group_name" {}

variable "cloudwatch_log_group_retention_in_days" {}

variable "ecs_cluster_name" {}

variable "ecs_policy_actions_resources" {}

variable "ecs_role_policy_identifiers" {}

variable "ecs_service_container_name" {}

variable "ecs_service_container_grpc_port" {}

variable "ecs_service_container_port" {}

variable "ecs_service_deployment_minimum_healthy_percent" {}

variable "ecs_service_desired_count" {}

variable "ecs_service_name" {}

variable "ecs_task_definition_family" {}

variable "launch_configuration_associate_public_ip_address" {}

variable "launch_configuration_image_id" {}

variable "launch_configuration_instance_type" {}

variable "launch_configuration_key_name" {}

variable "launch_configuration_policy_actions_resources" {}

variable "launch_configuration_role_policy_identifiers" {}

variable "load_balancer_cross_zone_load_balancing" {}

variable "load_balancer_name" {}

variable "region" {}

variable "route53_record_name" {}

variable "route53_record_zone_id" {}

variable "security_group_rules_cidr_blocks_ec2_instance_web" {}

variable "security_group_rules_cidr_blocks_load_balancer_web" {}

variable "security_group_rules_source_security_group_id_ec2_instance_web" {}

variable "ssl_certificate_id" {}

variable "subnet_cidr_blocks_private" {}

variable "subnet_cidr_blocks_public" {}

variable "vpc_cidr_block" {}
