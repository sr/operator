resource "aws_security_group" "cloned_chef_server" {
  name = "cloned_chef_server"
  description = "Cloned Chef Server for testing"
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cloned_chef_server" {
  ami = "ami-d6b552bb"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a.id}"
  vpc_security_group_ids = [
    "${aws_security_group.cloned_chef_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-chef1-2-ue1"
  }
}
