resource "aws_security_group" "appdev_chef_server" {
  name        = "appdev_chef_server"
  description = "Chef Server for the AWS environment"
  vpc_id      = "${aws_vpc.appdev.id}"

  # https://docs.chef.io/server_firewalls_and_ports.html
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${var.pardot_ci_vpc_cidr}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${var.pardot_ci_vpc_cidr}",
    ]
  }

  ingress {
    from_port = 9683
    to_port   = 9683
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${var.pardot_ci_vpc_cidr}",
    ]
  }

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.appdev_vpc_default.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "appdev_chef_server" {
  ami           = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name      = "internal_apps"
  private_ip    = "172.26.64.254"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"

  vpc_security_group_ids = [
    "${aws_security_group.appdev_chef_server.id}",
    "${aws_security_group.appdev_vpc_default.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = false
  }

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-chef1-1-${var.environment_appdev["dc_id"]}"
    terraform = true
  }
}

resource "aws_route53_record" "appdev_chef1_arecord" {
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot2-chef1-1-ue1.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.appdev_chef_server.private_ip}"]
  type    = "A"
  ttl     = "900"
}
