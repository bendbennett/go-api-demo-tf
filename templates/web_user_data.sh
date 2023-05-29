#!/bin/bash -xe
echo "ECS_CLUSTER=${cluster_id}" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m" >> /etc/ecs/ecs.config
yum update -y ecs-init
echo "DOCKER_STORAGE_OPTIONS=\"--storage-driver overlay2\"" > /etc/sysconfig/docker-storage
service docker restart
start ecs