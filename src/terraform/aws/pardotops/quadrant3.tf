resource "aws_db_instance" "q3db" {
  allocated_storage    = 50
  engine               = "mysql"
  engine_version       = "5.6.17"
  instance_class       = "db.t1.micro"
  name                 = "mydb"
  username             = "pardottandp"
  password             = "thisIsNotThePasswordAnymore" # once changed, this is no longer tracked by TF. See secrets.ops.pardot.com for latest PW
  db_subnet_group_name = "q3db_db_subnet_group"
  parameter_group_name = "default.mysql5.6"

  vpc_security_group_ids = [
    "${aws_security_group.q3_secgroup.id}",
  ]
}

resource "aws_db_subnet_group" "q3db_db_subnet_group" {
  name = "q3db_db_subnet_group"

  subnet_ids = [
    "${aws_subnet.appdev_us_east_1a_dmz.id}",
  ]
}

resource "aws_security_group" "q3_secgroup" {
  vpc_id      = "${aws_vpc.appdev}"
  description = "q3_secgroup"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "mysql"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "q3_secgroup"
    terraform = "true"
  }
}
