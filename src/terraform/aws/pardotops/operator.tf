resource "aws_ecs_cluster" "operator_production" {
  name = "operator_production"
}

resource "aws_ecs_task_definition" "operator_production" {
  family = "operator_production"
  container_definitions = "${file("operator.json")}"
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
  min_size = 0
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
