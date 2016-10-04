resource "aws_security_group" "internal_apps_operator_http_lb" {
  name = "internal_apps_operator_http_lb"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${aws_security_group.internal_apps_dc_only_http_lb.id}",
      "${aws_route53_record.hipchat_dev_pardot_com_Arecord.records[0]}/32"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "operator_production" {
  security_groups = ["${aws_security_group.internal_apps_operator_http_lb.id}"]
  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  ]
  enable_deletion_protection = true

  tags {
    Name = "operator_production"
  }
}

resource "aws_alb_target_group" "operator" {
  name     = "operator_target_group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.internal_apps.id}"

  health_check {
    path = "/_ping"
  }
}

resource "aws_alb_listener" "operator" {
  load_balancer_arn = "${aws_alb.operator_production.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"

  default_action {
    target_group_arn = "${aws_alb_target_group.operator.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "operator_healthcheck" {
  listener_arn = "${aws_alb_listener.operator.arn}"
  priority = 1

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.operator.arn}"
  }

  condition {
    field = "path-pattern"
    values = ["/_ping"]
  }
}

resource "aws_alb_listener_rule" "operator_hipchat" {
  listener_arn = "${aws_alb_listener.operator.arn}"
  priority = 2

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.operator.arn}"
  }

  condition {
    field = "path-pattern"
    values = ["/hipchat/*"]
  }
}

resource "aws_ecs_cluster" "operator_production" {
  name = "operator_production"
}

resource "aws_ecs_service" "operator_production" {
  name = "operator"
  cluster = "${aws_ecs_cluster.operator_production.id}"
  task_definition = "${aws_ecs_task_definition.operator.arn}"
  desired_count = 2
  iam_role = "arn:aws:iam::364709603225:role/ecsServiceRole"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.operator.arn}"
    container_name = "operatord"
    container_port = 8080
  }
}

resource "aws_ecs_task_definition" "operator" {
  family = "operator"
  container_definitions = "${file("operator.json")}"

  volume {
    name = "zoneinfo"
    host_path = "/usr/share/zoneinfo"
  }
}

resource "aws_security_group" "operator_app_production" {
  name = "operator_app_production"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.internal_apps_bastion.id}"
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.internal_apps_operator_http_lb.id}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "operator_db_production" {
  name = "operator_db_production"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.operator_app_production.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "operator_production" {
  identifier = "operator-production"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "5.6.23"
  instance_class = "db.t2.small"
  storage_type = "gp2"
  name = "operator_production"
  username = "operator"
  password = "choy8seoGuveelo"
  maintenance_window = "Tue:00:00-Tue:04:00"
  multi_az = true
  publicly_accessible = false
  db_subnet_group_name = "${aws_db_subnet_group.internal_apps.name}"
  vpc_security_group_ids = ["${aws_security_group.operator_db_production.id}"]
  storage_encrypted = false
  backup_retention_period = 5
  apply_immediately = true
}

resource "template_file" "operator_production_user_data" {
  template = "${file("ecs_user_data.tpl")}"

  vars {
    configuration_environment = "production"
    ecs_cluster = "operator_production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "operator_ecs_cluster_role" {
  assume_role_policy = "${file("ec2_instance_trust_relationship.json")}"
}

resource "aws_iam_role_policy" "operator_ecs_cluster_role_policy" {
  name = "operator_ecs_cluster_role_policy"
  role = "${aws_iam_role.operator_ecs_cluster_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeClusters",
        "ecs:DescribeContainerInstances",
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListServices",
        "ecs:ListTaskDefinitions",
        "ecs:ListTasks",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService",

        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.pardotops_configuration.bucket}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.pardotops_configuration.bucket}/production/ecs/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "operator_ecs_instance_profile" {
  roles = [
    "${aws_iam_role.operator_ecs_cluster_role.id}"
  ]
}

resource "aws_launch_configuration" "operator_production" {
  name_prefix = "operator_production"
  image_id = "${var.ecs_ami_id}"
  instance_type = "t2.small"
  key_name = "internal_apps"
  iam_instance_profile = "${aws_iam_instance_profile.operator_ecs_instance_profile.id}"
  security_groups = ["${aws_security_group.operator_app_production.id}"]
  associate_public_ip_address = false
  user_data = "${template_file.operator_production_user_data.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "operator_production" {
  max_size = 2
  min_size = 2
  launch_configuration = "${aws_launch_configuration.operator_production.id}"
  vpc_zone_identifier = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
