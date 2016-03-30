resource "aws_security_group" "internal_apps_ldap_server" {
  name = "internal_apps_ldap_server"
  description = "Allow LDAP and LDAPS from SFDC datacenters and internal apps"
  vpc_id = "${aws_vpc.internal_apps.id}"

  # We run LDAP over port 80 to allow SFDC datacenters to connect to us, since
  # only 80, 443, and 25 are allowed outbound.
  #
  # LDAP is run on port 80, LDAPS is run on port 443.

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30"    # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30"    # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  # The rest of the internal apps communicate over the 'normal' ports
  ingress {
    from_port = 389
    to_port = 389
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.canoe_app_production.id}"
    ]
  }
  ingress {
    from_port = 389
    to_port = 389
    protocol = "tcp"
    cidr_blocks = [
      "173.192.141.222/32" # tools-s1 (password.pardot.com)
    ]
  }
  ingress {
    from_port = 636
    to_port = 636
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.canoe_app_production.id}"
    ]
  }
  ingress {
    from_port = 636
    to_port = 636
    protocol = "tcp"
    cidr_blocks = [
      "173.192.141.222/32" # tools-s1 (password.pardot.com)
    ]
  }

  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}",
      "${aws_eip.internal_apps_bastion.public_ip}/32"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ldap_master" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.internal_apps_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_ldap_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = false
  }
  tags {
    Name = "ldap_master"
  }
}

resource "aws_eip" "ldap_master" {
  vpc = true
  instance = "${aws_instance.ldap_master.id}"
}
