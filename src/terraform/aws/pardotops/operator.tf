resource "aws_ecs_cluster" "operator_production" {
  name = "operator_production"
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_apps_operator_http_lb" {
  name = "internal_apps_operator_http_lb"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
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

resource "aws_elb" "operator_production" {
  name = "operator-production"
  security_groups = ["${aws_security_group.internal_apps_operator_http_lb.id}"]
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
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/_ping"
    interval = 5
  }

  tags {
    Name = "operator_production"
  }
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

resource "aws_launch_configuration" "operator_production" {
  name_prefix = "operator_production"
  image_id = "${var.ecs_ami_id}"
  instance_type = "t2.small"
  key_name = "internal_apps"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
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
  max_size = 1
  min_size = 1
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
