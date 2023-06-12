variable "autoscaling_group_desired_capacity" {}

variable "autoscaling_group_health_check_type" {}

variable "autoscaling_group_max_size" {}

variable "autoscaling_group_min_size" {}

variable "availability_zones" {
  type    = list(string)
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"
  ]
}

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

variable "load_balancer_security_group_rules_cidr_blocks" {
  type = list(
    object(
      {
        cidr_blocks = string
        from_port   = number
        protocol    = string
        to_port     = number
        type        = string
      }
    )
  )
  default = [
    {
      cidr_blocks = "0.0.0.0/0",
      from_port   = 80,
      protocol    = "tcp"
      to_port     = 80,
      type        = "ingress"
    },
    {
      cidr_blocks = "0.0.0.0/0",
      from_port   = 443,
      protocol    = "tcp"
      to_port     = 443,
      type        = "ingress"
    },
    {
      cidr_blocks = "0.0.0.0/0",
      from_port   = 50051,
      protocol    = "tcp"
      to_port     = 50051,
      type        = "ingress"
    },
    {
      cidr_blocks = "0.0.0.0/0",
      from_port   = 0,
      protocol    = "-1"
      to_port     = 0,
      type        = "egress"
    }
  ]
}

variable "region" {}

variable "route53_record_name" {}

variable "route53_record_zone_id" {}

variable "security_group_rules_cidr_blocks_ec2_instance_web" {
  type = list(
    object(
      {
        cidr_blocks = string
        from_port   = number
        protocol    = string
        to_port     = number
        type        = string
      }
    )
  )
  default = [
    {
      cidr_blocks = "0.0.0.0/0",
      from_port   = 0,
      protocol    = "-1"
      to_port     = 0,
      type        = "egress"
    }
  ]
}

variable "security_group_rules_source_security_group_id_ec2_instance_web" {
  type = list(
    object(
      {
        from_port = number
        protocol  = string
        to_port   = number
        type      = string
      }
    )
  )
  default = [
    {
      from_port = 80,
      protocol  = "tcp"
      to_port   = 80,
      type      = "ingress"
    },
    {
      from_port = 50051,
      protocol  = "tcp"
      to_port   = 50051,
      type      = "ingress"
    },
  ]
}

variable "ssl_certificate_id" {}

variable "subnet_private_cidr_blocks" {
  type    = list(string)
  default = [
    "10.0.128.0/24",
    "10.0.129.0/24",
    "10.0.130.0/24"
  ]
}

variable "subnet_public_cidr_blocks" {
  type    = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
