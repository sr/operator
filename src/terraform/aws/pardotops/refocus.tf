resource "aws_ecs_cluster" "refocus_production" {
  name = "refocus_production"
}

resource "template_file" "refocus_production_user_data" {
  template = "${file("ecs_user_data.tpl")}"

  vars {
    configuration_environment = "production"
    ecs_cluster               = "refocus_production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "refocus_app_production" {
  name   = "refocus_app_production"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "refocus_production" {
  name_prefix                 = "refocus_production"
  image_id                    = "${var.ecs_ami_id}"
  instance_type               = "t2.small"
  key_name                    = "internal_apps"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  security_groups             = ["${aws_security_group.refocus_app_production.id}"]
  associate_public_ip_address = false
  user_data                   = "${template_file.refocus_production_user_data.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "refocus_production" {
  max_size             = 1
  min_size             = 1
  launch_configuration = "${aws_launch_configuration.refocus_production.id}"

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
