resource "aws_security_group" "artifactory_instance_secgroup" {
  name = "artifactory_instance_secgroup"
  vpc_id = "${aws_vpc.internal_apps.id}"

  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.internal_apps_bastion.id}"
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_elb_secgroup" {
  name = "artifactory_elb_secgroup"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_mysql_secgroup" {
  name = "artifactory_mysql_secgroup"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "mysql"
    security_groups = [
      "${aws_security_group.artifactory_instance_secgroup.id}"
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot0-artifactory1-1-ue1" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "m4.xlarge"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.internal_apps_bastion.id}", "${aws_security_group.internal_apps_bastion.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "2047"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-artifactory1-1-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "elasticip_pardot0-artifactory1-1-ue1" {
  vpc = true
  instance = "${aws_instance.pardot0-artifactory1-1-ue1.id}"
}

resource "aws_instance" "pardot0-artifactory1-2-ue1" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "m4.xlarge"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.internal_apps_us_east_1d_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.internal_apps_bastion.id}","${aws_security_group.artifactory_instance_secgroup.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "2047"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-artifactory1-2-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "elasticip_pardot0-artifactory1-2-ue1" {
  vpc = true
  instance = "${aws_instance.pardot0-artifactory1-2-ue1.id}"
}

resource "aws_elb" "artifactory_ops_elb" {
  name = "artifactory-elb"
  security_groups = ["${aws_security_group.internal_apps_dc_only_http_lb.id}", "${aws_security_group.artifactory_elb_secgroup.id}"]
  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30
  instances = ["${aws_instance.pardot0-artifactory1-1-ue1.id}","${aws_instance.pardot0-artifactory1-2-ue1.id}"]

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/ops.pardot.com"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 4
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/artifactory/api/system/ping"
    interval = 5
  }

  tags {
    Name = "artifactory"
  }
}