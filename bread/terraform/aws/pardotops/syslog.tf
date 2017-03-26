resource "aws_security_group" "pardot0_ue1_syslog_server" {
  name        = "internal_apps_syslog_server"
  description = "Syslog Server for the AWS environment"
  vpc_id      = "${aws_vpc.pardot0_ue1.id}"

  # syslog from tooling
  ingress {
    from_port = 5140
    to_port   = 5140
    protocol  = "udp"

    cidr_blocks = [
      "${aws_vpc.pardot0_ue1.cidr_block}",
      "${aws_vpc.internal_tools_integration.cidr_block}",
    ]
  }

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.pardot0_ue1_bastion.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot0_ue1_syslog_server" {
  ami           = "${var.centos_7_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name      = "internal_apps"
  subnet_id     = "${aws_subnet.pardot0_ue1_1a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.pardot0_ue1_syslog_server.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "100"
    delete_on_termination = false
  }

  tags {
    Name      = "pardot0-syslog1-1-ue1"
    terraform = true
  }
}

resource "aws_route53_record" "pardot0_ue1_syslog1-1_Arecord" {
  zone_id = "${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-syslog1-1-ue1.aws.pardot.com"
  records = ["${aws_instance.pardot0_ue1_syslog_server.private_ip}"]
  type    = "A"
  ttl     = "900"
}
