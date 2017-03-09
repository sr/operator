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

# https://aws.amazon.com/blogs/compute/optimizing-disk-usage-on-amazon-ecs/
echo '#!/bin/bash
docker images -q | xargs --no-run-if-empty docker rmi' > /usr/local/bin/docker-cleanup
chmod +x /usr/local/bin/docker-cleanup
echo '00 00 * * * root /usr/local/bin/docker-cleanup' > /etc/cron.d/docker-cleanup
