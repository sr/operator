resource "aws_elasticache_subnet_group" "hal9000_production" {
  name        = "hal9000-production"
  description = "hal9000 production"

  subnet_ids = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}",
  ]
}

resource "aws_security_group" "hal9000_redis_production" {
  name   = "hal9000_redis_production"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.hal9000_app_production.id}",
      "${aws_security_group.operator_app_production.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "hal9000_production" {
  cluster_id               = "hal9000-production"
  engine                   = "redis"
  engine_version           = "2.8.24"
  maintenance_window       = "Tue:00:00-Tue:04:00"
  node_type                = "cache.m3.medium"
  num_cache_nodes          = 1
  parameter_group_name     = "default.redis2.8"
  port                     = 6379
  subnet_group_name        = "${aws_elasticache_subnet_group.hal9000_production.name}"
  security_group_ids       = ["${aws_security_group.hal9000_redis_production.id}"]
  snapshot_retention_limit = 30
  snapshot_window          = "04:00-06:00"
}

resource "aws_elb" "hal9000_production" {
  name            = "hal9000-production"
  security_groups = ["${aws_security_group.internal_apps_dc_only_http_lb.id}"]

  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}",
  ]

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 30

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/replication/_ping"
    interval            = 5
  }

  tags {
    Name = "hal9000_production"
  }
}

resource "aws_ecs_cluster" "hal9000_production" {
  name = "hal9000_production"
}

resource "aws_security_group" "hal9000_app_production" {
  name   = "hal9000_app_production"
  vpc_id = "${aws_vpc.internal_apps.id}"

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.internal_apps_bastion.id}",
    ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "template_file" "hal9000_production_user_data" {
  template = "${file("ecs_user_data.tpl")}"

  vars {
    configuration_environment = "production"
    ecs_cluster               = "hal9000_production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "hal9000_production" {
  name_prefix                 = "hal9000_production"
  image_id                    = "${var.ecs_ami_id}"
  instance_type               = "t2.small"
  key_name                    = "internal_apps"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  security_groups             = ["${aws_security_group.hal9000_app_production.id}"]
  associate_public_ip_address = false
  user_data                   = "${template_file.hal9000_production_user_data.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "hal9000_production" {
  max_size             = 1
  min_size             = 1
  launch_configuration = "${aws_launch_configuration.hal9000_production.id}"

  vpc_zone_identifier = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}
