resource "aws_security_group" "appdev_resty_server" {
  name        = "appdev_resty_server"
  description = "Rustyaboard Server for the AWS environment"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${var.aloha_vpn_cidr_blocks}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${var.aloha_vpn_cidr_blocks}",
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

resource "aws_instance" "appdev_resty_server" {
  ami           = "${var.centos_6_hvm_50gb_chefdev_ami}"
  instance_type = "t2.medium"
  key_name      = "internal_apps"
  private_ip    = "172.26.64.100"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"

  vpc_security_group_ids = [
    "${aws_security_group.appdev_resty_server.id}",
    "${aws_security_group.appdev_vpc_default.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "100"
    delete_on_termination = false
  }

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-resty1-1-${var.environment_appdev["dc_id"]}"
    terraform = true
  }
}

resource "aws_route53_record" "appdev_resty_arecord" {
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot2-resty1-1-ue1.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.appdev_resty_server.private_ip}"]
  type    = "A"
  ttl     = "900"
}
