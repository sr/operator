resource "aws_ecr_repository" "webpasswordsafe" {
  name = "webpasswordsafe"
}

resource "aws_elasticache_subnet_group" "wps_production" {
  name = "wps-production"
  description = "webpasswordsafe production"
  subnet_ids = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}"
  ]
}

resource "aws_elb" "wps_production" {
  name = "wps-production"
  security_groups = ["${aws_security_group.internal_apps_dc_only_http_lb.id}"]
  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8443
    instance_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTPS:8443/"
    interval = 5
  }

  tags {
    Name = "wps_production"
  }
}

resource "aws_launch_configuration" "wps_production" {
  name_prefix = "wps_production"
  image_id = "${var.ecs_ami_id}"
  instance_type = "t2.small"
  key_name = "internal_apps"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wps_production" {
  max_size = 1
  min_size = 1
  launch_configuration = "${aws_launch_configuration.wps_production.id}"
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

resource "aws_db_instance" "wps_production" {
  identifier = "wps_production-rds"
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.6.29"
  instance_class = "db.t1.micro"
  name = "${var.mysql_database}"
  username = "${var.mysql_username}"
  password = "${var.mysql_password}"
  storage_encrypted = true
  vpc_security_group_ids = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}"
  ]
  parameter_group_name = "default.mysql5.6"
}
