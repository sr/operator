resource "aws_instance" "appdev_zabbix1" {
  key_name = "internal_apps"
  ami = "${var.centos_6_hvm_50gb_chefdev_ami}"
  instance_type = "m4.xlarge"
  subnet_id = "${aws_subnet.appdev_us_east_1d.id}"
  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "512"
    delete_on_termination = true
  }
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_zabbix_host.id}"
  ]
  tags {
    Name = "pardot2-monitor1-1-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_zabbix_host_eip" {
  vpc = true
  instance = "${aws_instance.appdev_zabbix1.id}"
}

resource "aws_route53_record" "appdev_zabbix1_arecord" {
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name = "pardot2-monitor1-1-ue1.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_eip.appdev_zabbix_host_eip.public_ip}"]
  type = "A"
  ttl = "900"
}

resource "aws_route53_record" "appdev_zabbix-internal1_arecord" {
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name = "pardot2-monitor-internal1-1-ue1.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.appdev_zabbix1.private_ip}"]
  type = "A"
  ttl = "900"
}

resource "aws_security_group" "appdev_zabbix_host" {
  name = "appdev_zabbix_host"
  description = "allows traffic on 443 from the appdev vpc and the SFDC VPN"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${aws_nat_gateway.appdev_nat_gw.public_ip}/32",
      "${aws_vpc.appdev.cidr_block}",
      "${var.aloha_vpn_cidr_blocks}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

