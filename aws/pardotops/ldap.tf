resource "aws_security_group" "internal_apps_ldap_server_lb" {
  name = "internal_apps_ldap_server_lb"
  description = "External load balancer for the LDAP server"
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
      "173.192.141.222/32", # tools-s1 (password.pardot.com)
      "67.228.6.68/32"      # auth-d1
    ]
  }

  ingress {
    from_port = 636
    to_port = 636
    protocol = "tcp"
    cidr_blocks = [
      "173.192.141.222/32", # tools-s1 (password.pardot.com)
      "67.228.6.68/32"      # auth-d1
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "internal_apps_ldap_server" {
  name = "ldap-server"
  security_groups = ["${aws_security_group.internal_apps_ldap_server_lb.id}"]
  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30

  listener {
    lb_port = 80
    lb_protocol = "tcp"
    instance_port = 389
    instance_protocol = "tcp"
  }
  listener {
    lb_port = 443
    lb_protocol = "tcp"
    instance_port = 636
    instance_protocol = "tcp"
  }

  listener {
    lb_port = 389
    lb_protocol = "tcp"
    instance_port = 389
    instance_protocol = "tcp"
  }
  listener {
    lb_port = 636
    lb_protocol = "tcp"
    instance_port = 636
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:389"
    interval = 60
  }

  instances = [
    "${aws_instance.internal_apps_ldap_master.id}"
  ]
}

resource "aws_security_group" "internal_apps_ldap_admin_server_lb" {
  name = "internal_apps_ldap_admin_server_lb"
  description = "External load balancer for the LDAP admin frontend server"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "204.14.236.0/24",    # aloha-east
      "204.14.239.0/24",    # aloha-west
      "62.17.146.140/30",   # aloha-emea
      "62.17.146.144/28",   # aloha-emea
      "62.17.146.160/27",   # aloha-emea
    ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "204.14.236.0/24",    # aloha-east
      "204.14.239.0/24",    # aloha-west
      "62.17.146.140/30",   # aloha-emea
      "62.17.146.144/28",   # aloha-emea
      "62.17.146.160/27",   # aloha-emea
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "internal_apps_ldap_admin_server" {
  name = "ldap-admin-server"
  security_groups = ["${aws_security_group.internal_apps_ldap_admin_server_lb.id}"]
  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/ops.pardot.com"
  }


  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:80"
    interval = 60
  }

  instances = [
    "${aws_instance.internal_apps_ldap_master.id}"
  ]
}

resource "aws_security_group" "internal_apps_ldap_server" {
  name = "internal_apps_ldap_server"
  description = "Allow LDAP and LDAPS from SFDC datacenters and internal apps"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.internal_apps_ldap_admin_server_lb.id}"
    ]
  }
  ingress {
    from_port = 389
    to_port = 389
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}"
    ]
  }
  ingress {
    from_port = 636
    to_port = 636
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}"
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

resource "aws_instance" "internal_apps_ldap_master" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  private_ip = "172.30.93.181"
  subnet_id = "${aws_subnet.internal_apps_us_east_1d.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_ldap_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "ldap_master"
  }
}

resource "aws_route53_record" "ldap1_aws_ops_pardot_com" {
  zone_id = "${aws_route53_zone.internal_apps_ops_pardot_com.zone_id}"
  name = "ldap1-aws.ops.pardot.com"
  type = "A"
  ttl = "300"
  records = [
    "${aws_instance.internal_apps_ldap_master.private_ip}"
  ]
}

resource "aws_instance" "internal_apps_ldap_replica" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  private_ip = "172.30.1.110"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_ldap_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "ldap_replica"
  }
}

resource "aws_route53_record" "ldap2_aws_ops_pardot_com" {
  zone_id = "${aws_route53_zone.internal_apps_ops_pardot_com.zone_id}"
  name = "ldap2-aws.ops.pardot.com"
  type = "A"
  ttl = "300"
  records = [
    "${aws_instance.internal_apps_ldap_replica.private_ip}"
  ]
}
