resource "aws_security_group" "artifact_cache_http_lb" {
  name = "artifactory_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "192.168.128.0/22"    # bamboo instances in pardot-artifactory
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifact_cache_server" {
  name = "artifact_cache_server"
  description = "Allow HTTP from Artifact Cache LB"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.internal_apps_bastion.id}"
    ]
  }

  ingress = {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.artifact_cache_http_lb.id}"
    ]
  }
}

resource "aws_elb" "artifact_cache_lb" {
  name = "artifact-cache-lb"
  security_groups = ["${aws_security_group.artifact_cache_http_lb.id}"]
  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a.id}",
    "${aws_subnet.artifactory_integration_us_east_1c.id}",
    "${aws_subnet.artifactory_integration_us_east_1d.id}",
    "${aws_subnet.artifactory_integration_us_east_1e.id}",
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30
  internal = true

  instances = [
    "${aws_instance.artifact_cache_server_1.id}",
    "${aws_instance.artifact_cache_server_2.id}",
    "${aws_instance.artifact_cache_server_3.id}",
    "${aws_instance.artifact_cache_server_4.id}"
  ]

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
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 5
  }

  tags {
    Name = "artifact-cache-lb"
  }
}

resource "aws_instance" "artifact_cache_server_1" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "c4.xlarge"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1a.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "512"
    delete_on_termination = true
  }
  tags {
    terraform = "true"
    Name = "pardot0-artifactcache1-1-ue1"
  }
}
resource "aws_instance" "artifact_cache_server_2" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "c4.xlarge"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1c.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "512"
    delete_on_termination = true
  }
  tags {
    terraform = "true"
    Name = "pardot0-artifactcache1-2-ue1"
  }
}
resource "aws_instance" "artifact_cache_server_3" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "c4.xlarge"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1d.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "512"
    delete_on_termination = true
  }
  tags {
    terraform = "true"
    Name = "pardot0-artifactcache1-3-ue1"
  }
}
resource "aws_instance" "artifact_cache_server_4" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "c4.xlarge"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1e.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "512"
    delete_on_termination = true
  }
  tags {
    terraform = "true"
    Name = "pardot0-artifactcache1-4-ue1"
  }
}
