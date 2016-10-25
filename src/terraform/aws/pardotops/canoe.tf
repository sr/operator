resource "aws_elb" "canoe_production" {
  name            = "canoe-production"
  security_groups = ["${aws_security_group.internal_apps_canoe_http_lb.id}"]

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
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

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
    target              = "HTTP:80/_ping"
    interval            = 5
  }

  tags {
    Name = "canoe_production"
  }
}

resource "aws_security_group" "canoe_db_production" {
  name   = "canoe_db_production"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.canoe_app_production.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "canoe_production" {
  identifier              = "canoe-production"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "5.6.23"
  instance_class          = "db.t2.small"
  storage_type            = "gp2"
  name                    = "canoe_production"
  username                = "canoe"
  password                = "WeGDb6pjqgayjMSnnm7U"
  maintenance_window      = "Tue:00:00-Tue:04:00"
  multi_az                = true
  publicly_accessible     = false
  db_subnet_group_name    = "${aws_db_subnet_group.internal_apps.name}"
  vpc_security_group_ids  = ["${aws_security_group.canoe_db_production.id}"]
  storage_encrypted       = false
  backup_retention_period = 30
  apply_immediately       = true
}

resource "aws_ecs_cluster" "canoe_production" {
  name = "canoe_production"
}

resource "aws_security_group" "internal_apps_canoe_http_lb" {
  name   = "internal_apps_canoe_http_lb"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${concat(var.aloha_vpn_cidr_blocks, var.sfdc_proxyout_cidr_blocks)}"
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_eip.internal_apps_nat_gw.public_ip}/32",
      "${aws_eip.appdev_nat_gw.public_ip}/32",
      "${aws_eip.appdev_proxyout1_eip.public_ip}/32",
    ]

    security_groups = [
      "${aws_security_group.internal_apps_chef_server.id}",
    ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${concat(var.aloha_vpn_cidr_blocks, var.sfdc_proxyout_cidr_blocks)}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "canoe_app_production" {
  name   = "canoe_app_production"
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

data "template_file" "canoe_production_user_data" {
  template = "${file("ecs_user_data.tpl")}"

  vars {
    configuration_environment = "production"
    ecs_cluster               = "canoe_production"
  }
}

resource "aws_launch_configuration" "canoe_production" {
  name_prefix                 = "canoe_production"
  image_id                    = "${var.ecs_ami_id}"
  instance_type               = "t2.small"
  key_name                    = "internal_apps"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  security_groups             = ["${aws_security_group.canoe_app_production.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.canoe_production_user_data.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "canoe_production" {
  max_size             = 2
  min_size             = 2
  launch_configuration = "${aws_launch_configuration.canoe_production.id}"

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
