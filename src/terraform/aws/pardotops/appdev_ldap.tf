resource "aws_security_group" "appdev_ldap_server" {
  name = "appdev_ldap_server"
  description = "Allow LDAP and LDAPS inside appdev VPC"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 389
    to_port = 389
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}"
    ]
  }
  ingress {
    from_port = 636
    to_port = 636
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}"
    ]
  }

  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.appdev_vpc_default.id}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "appdev_ldap_host" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  private_ip = "172.26.192.254"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_ldap_server.id}",
    "${aws_security_group.appdev_vpc_default.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-auth1-1-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_ldap_host_eip" {
  vpc = true
  instance = "${aws_instance.appdev_ldap_host.id}"
}