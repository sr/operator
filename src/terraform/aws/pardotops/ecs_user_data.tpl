#!/bin/bash
set -ex

yum update -y

yum install -y aws-cli
aws s3 cp s3://pardotops-configuration/${configuration_environment}/ecs/ecs.config /etc/ecs/ecs.config
sed -i'' 's/{{ECS_CLUSTER}}/${ecs_cluster}/g' /etc/ecs/ecs.config

yum install -y awslogs-1.1.2
sed -i 's/log_group_name = \/var\/log\/messages/log_group_name = bread/g' /etc/awslogs/awslogs.conf
service awslogs start
chkconfig awslogs on
