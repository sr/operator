// Ceph configuration for appdev

// Security group for all RGWs (allows cross-cluster replication)
resource "aws_security_group" "appdev_ceph_global_rgw" {
  name        = "appdev_ceph_global_rgw"
  description = "Allow cross-cluster replication"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// CLUSTER 1

// Ceph RGW/Monitor hosts Security Group
resource "aws_security_group" "appdev_cephrgw1" {
  name        = "appdev_cephrgw1"
  description = "Allow traffic to Ceph RGW and Mon services"
  vpc_id      = "${aws_vpc.appdev.id}"

  // Need to be able to talk to itself on the Ceph Monitor port since the RGW
  // service checks in with the mon over the configured IP and not through localhost
  ingress {
    from_port = 6789
    to_port   = 6789
    protocol  = "tcp"
    self      = true
  }

  // Allow port 80 from the ELB to the RGW host(s)
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.appdev_cephelb1.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_ceph_cluster1" {
  name        = "appdev_ceph_cluster1"
  description = "Allow specific ports within the cluster for each type"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 6789
    to_port   = 6789
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 6800
    to_port   = 7300
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Security group for the OSD servers
resource "aws_security_group" "appdev_cephosd1" {
  name        = "appdev_cephosd1"
  description = "Allow traffic to Ceph OSD service"
  vpc_id      = "${aws_vpc.appdev.id}"

  // The OSDs need to be able to talk with each other for health checks and data
  // replication
  ingress {
    from_port = 6800
    to_port   = 7300
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// ELB Security Group
resource "aws_security_group" "appdev_cephelb1" {
  name        = "appdev_cephelb1"
  description = "Allow MYSQL traffic from appdev apphosts"
  vpc_id      = "${aws_vpc.appdev.id}"

  // Allow for people on the VPN to access the ELB for "aws s3" cli access as well
  // as for web browsers to be able to view static assets where needed
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${aws_nat_gateway.appdev_nat_gw.public_ip}/32",
      "${aws_nat_gateway.appdev_nat_gw.private_ip}/32",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.appdev_vpc_default.id}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${aws_nat_gateway.appdev_nat_gw.public_ip}/32",
      "${aws_nat_gateway.appdev_nat_gw.private_ip}/32",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
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

// Create the actual ELB
resource "aws_elb" "appdev_rgw1_elb" {
  name = "${var.environment_appdev["env_name"]}-rgw1-elb"

  security_groups = [
    "${aws_security_group.appdev_cephelb1.id}",
  ]

  subnets = [
    "${aws_subnet.appdev_us_east_1a_dmz.id}",
    "${aws_subnet.appdev_us_east_1c_dmz.id}",
    "${aws_subnet.appdev_us_east_1d_dmz.id}",
    "${aws_subnet.appdev_us_east_1e_dmz.id}",
  ]

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 30
  instances                   = ["${aws_instance.appdev_cephrgw1.*.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "arn:aws:iam::${var.pardotops_account_number}:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 5
  }

  tags {
    Name = "appdev_rgw1_elb"
  }
}

resource "aws_route53_record" "files_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "files.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_elb.appdev_rgw1_elb.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

// CEPH RGW/Monitor instance(s)
resource "aws_instance" "appdev_cephrgw1" {
  key_name      = "internal_apps"
  count         = "${var.environment_appdev["num_cephrgw1_hosts"]}"
  ami           = "${var.ceph-chef-ami}"
  instance_type = "${var.environment_appdev["ceph_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"
  ebs_optimized = "true"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_ceph_global_rgw.id}",
    "${aws_security_group.appdev_ceph_cluster1.id}",
    "${aws_security_group.appdev_cephrgw1.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-cephrgw1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }

  provisioner "remote-exec" {
    inline = [
      "zfs set xattr=sa data",
      "zfs set atime=off data",
      "zfs set compression=lz4 data",
      "zfs create -V 93G data/ceph",
      "mkfs.xfs /dev/zvol/data/ceph",
      "mkdir -p /var/lib/ceph",
      "mount /dev/zvol/data/ceph /var/lib/ceph",
      "echo '/dev/zd0        /var/lib/ceph   xfs     defaults,noatime        0 0' | tee -a /ec/fstab",
    ]
  }
}

resource "aws_route53_record" "appdev_cephrgw1_arecord" {
  count   = "${var.environment_appdev["num_cephrgw1_hosts"]}"
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-cephrgw1-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_cephrgw1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "appdev_cephosd1" {
  key_name      = "internal_apps"
  count         = "${var.environment_appdev["num_cephosd1_hosts"]}"
  ami           = "${var.ceph-chef-ami}"
  instance_type = "${var.environment_appdev["ceph_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"
  ebs_optimized = "true"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_ceph_cluster1.id}",
    "${aws_security_group.appdev_cephosd1.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-cephosd1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }

  provisioner "remote-exec" {
    inline = [
      "zfs set xattr=sa data",
      "zfs set atime=off data",
      "zfs set compression=lz4 data",
      "zfs create -V 93G data/ceph",
      "mkfs.xfs /dev/zvol/data/ceph",
      "mkdir -p /var/lib/ceph",
      "mount /dev/zvol/data/ceph /var/lib/ceph",
      "echo '/dev/zd0        /var/lib/ceph   xfs     defaults,noatime        0 0' | tee -a /ec/fstab",
    ]
  }
}

resource "aws_route53_record" "appdev_cephosd1_arecord" {
  count   = "${var.environment_appdev["num_cephosd1_hosts"]}"
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-cephosd1-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_cephosd1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

// CLUSTER 2
resource "aws_security_group" "appdev_ceph_cluster2" {
  name        = "appdev_ceph_cluster2"
  description = "Allow specific ports within the cluster for each type"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 6789
    to_port   = 6789
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 6800
    to_port   = 7300
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_cephrgw2" {
  name        = "appdev_cephrgw2"
  description = "Allow traffic to Ceph RGW and Mon services"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 6789
    to_port   = 6789
    protocol  = "tcp"
    self      = true
  }

  // Allow port 80 from the ELB to the RGW host(s)
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.appdev_cephelb2.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_cephosd2" {
  name        = "appdev_cephosd2"
  description = "Allow traffic to Ceph OSD service"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 6800
    to_port   = 7300
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_cephelb2" {
  name        = "appdev_cephelb2"
  description = "Allow MYSQL traffic from appdev apphosts"
  vpc_id      = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${aws_nat_gateway.appdev_nat_gw.public_ip}/32",
      "${aws_nat_gateway.appdev_nat_gw.private_ip}/32",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.appdev_vpc_default.id}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${aws_nat_gateway.appdev_nat_gw.public_ip}/32",
      "${aws_nat_gateway.appdev_nat_gw.private_ip}/32",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
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

resource "aws_elb" "appdev_rgw2_elb" {
  name = "${var.environment_appdev["env_name"]}-rgw2-elb"

  security_groups = [
    "${aws_security_group.appdev_cephelb2.id}",
  ]

  subnets = [
    "${aws_subnet.appdev_us_east_1a_dmz.id}",
    "${aws_subnet.appdev_us_east_1c_dmz.id}",
    "${aws_subnet.appdev_us_east_1d_dmz.id}",
    "${aws_subnet.appdev_us_east_1e_dmz.id}",
  ]

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 30
  instances                   = ["${aws_instance.appdev_cephrgw2.*.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "arn:aws:iam::${var.pardotops_account_number}:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 5
  }

  tags {
    Name = "appdev_rgw2_elb"
  }
}

resource "aws_route53_record" "files2_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "files2.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_elb.appdev_rgw2_elb.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_instance" "appdev_cephrgw2" {
  key_name      = "internal_apps"
  count         = "${var.environment_appdev["num_cephrgw2_hosts"]}"
  ami           = "${var.ceph-chef-ami}"
  instance_type = "${var.environment_appdev["ceph_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1c.id}"
  ebs_optimized = "true"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_ceph_global_rgw.id}",
    "${aws_security_group.appdev_ceph_cluster2.id}",
    "${aws_security_group.appdev_cephrgw2.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-cephrgw2-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }

  provisioner "remote-exec" {
    inline = [
      "zfs set xattr=sa data",
      "zfs set atime=off data",
      "zfs set compression=lz4 data",
      "zfs create -V 93G data/ceph",
      "mkfs.xfs /dev/zvol/data/ceph",
      "mkdir -p /var/lib/ceph",
      "mount /dev/zvol/data/ceph /var/lib/ceph",
      "echo '/dev/zd0        /var/lib/ceph   xfs     defaults,noatime        0 0' | tee -a /ec/fstab",
    ]
  }
}

resource "aws_route53_record" "appdev_cephrgw2_arecord" {
  count   = "${var.environment_appdev["num_cephrgw2_hosts"]}"
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-cephrgw2-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_cephrgw2.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "appdev_cephosd2" {
  key_name      = "internal_apps"
  count         = "${var.environment_appdev["num_cephosd2_hosts"]}"
  ami           = "${var.ceph-chef-ami}"
  instance_type = "${var.environment_appdev["ceph_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1c.id}"
  ebs_optimized = "true"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_ceph_cluster2.id}",
    "${aws_security_group.appdev_cephosd2.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-cephosd2-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }

  provisioner "remote-exec" {
    inline = [
      "zfs set xattr=sa data",
      "zfs set atime=off data",
      "zfs set compression=lz4 data",
      "zfs create -V 93G data/ceph",
      "mkfs.xfs /dev/zvol/data/ceph",
      "mkdir -p /var/lib/ceph",
      "mount /dev/zvol/data/ceph /var/lib/ceph",
      "echo '/dev/zd0        /var/lib/ceph   xfs     defaults,noatime        0 0' | tee -a /ec/fstab",
    ]
  }
}

resource "aws_route53_record" "appdev_cephosd2_arecord" {
  count   = "${var.environment_appdev["num_cephosd2_hosts"]}"
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-cephosd2-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_cephosd2.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}
