resource "aws_security_group" "internal_apps_chef_server" {
  name = "internal_apps_chef_server"
  description = "Chef Server for the AWS environment"
  vpc_id = "${aws_vpc.internal_apps.id}"

  # https://docs.chef.io/server_firewalls_and_ports.html
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}"
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}"
    ]
  }

  ingress {
    from_port = 9683
    to_port = 9683
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.internal_apps.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}"
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

resource "aws_instance" "internal_apps_chef_server" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  private_ip = "172.30.22.109"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_chef_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-chef1-1-ue1"
    terraform = true
  }
}

resource "aws_route53_record" "internal_apps_chef1-1_Arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name = "pardot0-chef1-1-ue1.aws.pardot.com"
  records = ["${aws_instance.internal_apps_chef_server.private_ip}"]
  type = "A"
  ttl = "900"
}

#TODO: remove all artifactory-integration route53 records and replace w/ dns-sharing w/ internal_apps
resource "aws_route53_record" "artifactory_integration_chef1-1_Arecord" {
  zone_id = "${aws_route53_zone.artifactory_integration_aws_pardot_com_hosted_zone.zone_id}"
  name = "pardot0-chef1-1-ue1.aws.pardot.com"
  records = ["${aws_instance.internal_apps_chef_server.private_ip}"]
  type = "A"
  ttl = "900"
}

