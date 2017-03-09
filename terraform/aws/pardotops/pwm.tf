resource "aws_elb" "pwm_production" {
  name            = "pwm-production"
  security_groups = ["${aws_security_group.pardot0_ue1_http_lb.id}"]

  subnets = [
    "${aws_subnet.pardot0_ue1_1a_dmz.id}",
    "${aws_subnet.pardot0_ue1_1c_dmz.id}",
    "${aws_subnet.pardot0_ue1_1d_dmz.id}",
    "${aws_subnet.pardot0_ue1_1e_dmz.id}",
  ]

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 30

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/ops.pardot.com"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 3
    target              = "HTTP:80/pwm/public/rest/health"
    interval            = 5
  }

  tags {
    Name = "pwm_production"
  }
}

resource "aws_ecs_cluster" "pwm_production" {
  name = "pwm_production"
}

resource "aws_security_group" "pwm_app_production" {
  name   = "pwm_app_production"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.pardot0_ue1_bastion.id}",
    ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.pardot0_ue1.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "pwm_production_user_data" {
  template = "${file("ecs_user_data.tpl")}"

  vars {
    configuration_environment = "production"
    ecs_cluster               = "pwm_production"
  }
}

resource "aws_launch_configuration" "pwm_production" {
  name_prefix                 = "pwm_production"
  image_id                    = "${var.ecs_ami_id}"
  instance_type               = "t2.small"
  key_name                    = "internal_apps"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  security_groups             = ["${aws_security_group.pwm_app_production.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.pwm_production_user_data.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "pwm_production" {
  max_size             = 1
  min_size             = 1
  launch_configuration = "${aws_launch_configuration.pwm_production.id}"

  vpc_zone_identifier = [
    "${aws_subnet.pardot0_ue1_1a.id}",
    "${aws_subnet.pardot0_ue1_1c.id}",
    "${aws_subnet.pardot0_ue1_1d.id}",
    "${aws_subnet.pardot0_ue1_1e.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "password_ops_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.ops_pardot_com.zone_id}"
  name    = "password.${aws_route53_zone.ops_pardot_com.name}"
  records = ["${aws_elb.pwm_production.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}
