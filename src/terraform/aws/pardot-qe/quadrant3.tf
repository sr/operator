resource "aws_db_instance" "q3db" {
  allocated_storage    = 50
  engine               = "postgres"
  instance_class       = "db.t2.small"
  name                 = "q3db"
  username             = "pardottandp"
  password             = "thisIsNotThePasswordAnymore" # once changed, this is no longer tracked by TF. See secrets.ops.pardot.com for latest PW
  parameter_group_name = "default.postgres9.5"

  vpc_security_group_ids = [
    "${aws_security_group.q3_db_secgroup.id}",
  ]

  db_subnet_group_name = "${aws_db_subnet_group.q3db_subnet_group.name}"
}

resource "aws_db_subnet_group" "q3db_subnet_group" {
  name = "q3_db_subnet_group"
  subnet_ids = [
    "${aws_subnet.dev_environment_us_east_1c.id}"
  ]
}

resource "aws_security_group" "q3_db_secgroup" {
  description = "q3_secgroup"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"

    cidr_blocks = [
      "${aws_instance.q3_apphost.private_ip}/32",
      "${aws_eip.q3_eip.public_ip}/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "q3_db_secgroup"
    terraform = "true"
  }
}

resource "aws_instance" "q3_apphost" {
  ami                         = "${var.centos_7_hvm_ebs_ami}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.dev_environment_us_east_1c_dmz.id}"
  associate_public_ip_address = false
  key_name                    = "quadrant3"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.q3_app_secgroup.id}",
  ]
}

resource "aws_eip" "q3_eip" {
  instance = "${aws_instance.q3_apphost.id}"
  vpc      = true
}

resource "aws_security_group" "q3_app_secgroup" {
  description = "q3_secgroup"
  vpc_id      = "${aws_vpc.dev_environment.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "TCP"

    cidr_blocks = [
      "${var.jump_dot_dev_ip_address}/32",
      "${var.pardot2_proxyout_egress_ip}/32",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "204.14.236.0/24",               # aloha-east
      "204.14.239.0/24",               # aloha-west
      "62.17.146.140/30",              # aloha-emea
      "62.17.146.144/28",              # aloha-emea
      "62.17.146.160/27",              # aloha-emea
      "${var.pardot_ci_egress_ip}/32",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "204.14.236.0/24",               # aloha-east
      "204.14.239.0/24",               # aloha-west
      "62.17.146.140/30",              # aloha-emea
      "62.17.146.144/28",              # aloha-emea
      "62.17.146.160/27",              # aloha-emea
      "${var.pardot_ci_egress_ip}/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "q3_app_secgroup"
    terraform = "true"
  }
}
