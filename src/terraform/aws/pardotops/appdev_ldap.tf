resource "aws_security_group" "appdev_ldap_server" {
  name        = "appdev_ldap_server"
  description = "Allow LDAP and LDAPS inside appdev VPC"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 389
    to_port   = 389
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
    ]
  }

  ingress {
    from_port = 636
    to_port   = 636
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
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

resource "aws_instance" "appdev_ldap_host" {
  ami           = "${var.centos_6_hvm_50gb_chefdev_ami_LDAP_AUTH_HOST_ONLY}"
  instance_type = "t2.medium"
  key_name      = "internal_apps"
  private_ip    = "172.26.192.254"
  subnet_id     = "${aws_subnet.appdev_us_east_1d_dmz.id}"

  vpc_security_group_ids = [
    "${aws_security_group.appdev_ldap_server.id}",
    "${aws_security_group.appdev_vpc_default.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = false
  }

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-auth1-1-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_ldap_host_eip" {
  vpc      = true
  instance = "${aws_instance.appdev_ldap_host.id}"
}

resource "aws_route53_record" "appdev_internal_apps_ldap_master_Arecord" {
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-auth1-1-ue1.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_eip.internal_apps_ldap_master.public_ip}"]
  ttl     = "900"
  type    = "A"
}

resource "aws_route53_record" "appdev_auth1_arecord" {
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot2-auth1-1-ue1.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_eip.appdev_ldap_host_eip.private_ip}"]
  ttl     = "900"
  type    = "A"
}
