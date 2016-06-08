resource "aws_security_group" "internal_apps_ldap_server" {
  name = "internal_apps_ldap_server"
  description = "Allow LDAP and LDAPS from SFDC datacenters and internal apps"
  vpc_id = "${aws_vpc.internal_apps.id}"

  # We run LDAP over port 443 to allow SFDC datacenters to connect to us, since
  # only 80, 443, and 25 are allowed outbound.
  #
  # LDAPS is run on port 443.

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

  ingress {
    from_port = 389
    to_port = 389
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}",
      "${aws_eip.internal_apps_nat_gw.public_ip}/32",
      "52.21.58.50/32",     # artifactory.dev.pardot.com
      "52.4.132.69/32",     # 1.git.dev.pardot.com
      "52.3.83.197/32",     # 2.git.dev.pardot.com
      "173.192.141.222/32", # tools-s1 (password.pardot.com)
      "67.228.6.68/32"      # auth-d1
    ]
  }
  ingress {
    from_port = 636
    to_port = 636
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}",
      "${aws_eip.internal_apps_nat_gw.public_ip}/32",
      "52.21.58.50/32",     # artifactory.dev.pardot.com
      "52.4.132.69/32",     # 1.git.dev.pardot.com
      "52.3.83.197/32",     # 2.git.dev.pardot.com
      "173.192.141.222/32", # tools-s1 (password.pardot.com)
      "67.228.6.68/32"      # auth-d1
    ]
  }

  # SSH from bastion
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

resource "aws_iam_role" "internal_apps_ldap_master" {
  name = "internal_apps_ldap_master"
  assume_role_policy = "${file(\"ec2_instance_trust_relationship.json\")}"
}

resource "aws_iam_instance_profile" "internal_apps_ldap_master" {
  name = "internal_apps_ldap_master"
  roles = ["${aws_iam_role.internal_apps_ldap_master.id}"]
}

resource "aws_iam_role_policy" "internal_apps_ldap_master_policy" {
  name = "internal_apps_ldap_master_policy"
  role = "${aws_iam_role.internal_apps_ldap_master.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "internal_apps_ldap_master" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  iam_instance_profile = "${aws_iam_instance_profile.internal_apps_ldap_master.id}"
  key_name = "internal_apps"
  private_ip = "172.30.132.212"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_ldap_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-auth1-1-ue1"
  }
}

resource "aws_eip" "internal_apps_ldap_master" {
  vpc = true
  instance = "${aws_instance.internal_apps_ldap_master.id}"
}

resource "aws_instance" "internal_apps_ldap_replica" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  private_ip = "172.30.213.2"
  subnet_id = "${aws_subnet.internal_apps_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_ldap_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-auth1-2-ue1"
  }
}

resource "aws_eip" "internal_apps_ldap_replica" {
  vpc = true
  instance = "${aws_instance.internal_apps_ldap_replica.id}"
}