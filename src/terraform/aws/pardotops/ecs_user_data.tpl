#!/bin/bash
set -ex
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config
yum update -y
yum install -y awslogs-1.1.2
sed -i 's/log_group_name = \/var\/log\/messages/log_group_name = bread/g' /etc/awslogs/awslogs.conf
service awslogs start
chkconfig awslogs on
