variable "availability_zones" {}

variable "cloudwatch_log_group_name" {}

variable "cloudwatch_log_group_retention_in_days" {}

variable "ecs_cluster_name" {}

variable "launch_configuration_image_id" {}

variable "launch_configuration_instance_type" {}

variable "launch_configuration_policy_actions_resources" {}

variable "launch_configuration_role_policy_identifiers" {}

variable "launch_configuration_web_user_data_template" {}

variable "load_balancer_cross_zone_load_balancing" {}

variable "load_balancer_name" {}

variable "region" {}

variable "security_group_rules_cidr_blocks_ec2_instance_web" {}

variable "security_group_rules_cidr_blocks_load_balancer_web" {}

variable "security_group_rules_source_security_group_id_ec2_instance_web" {}

variable "ssl_certificate_id" {}

variable "subnet_cidr_blocks_private" {}

variable "subnet_cidr_blocks_public" {}

variable "vpc_cidr_block" {}
