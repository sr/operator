resource "aws_security_group" "pull_agent_dev" {
  name = "pull_agent_dev"
  vpc_id = "${aws_vpc.internal_apps.id}"

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

  tags {
    terraform = true
  }
}

resource "aws_instance" "pull_agent_dev" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.internal_apps_us_east_1d.id}"
  vpc_security_group_ids = [
    "${aws_security_group.pull_agent_dev.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = true
  }
  tags {
    Name = "pull_agent_dev"
    terraform = true
  }
}
