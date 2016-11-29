resource "aws_db_instance" "q3db" {
  allocated_storage    = 50
  engine               = "postgres"
  instance_class       = "db.t2.small"
  name                 = "mydb"
  username             = "pardottandp"
  password             = "thisIsNotThePasswordAnymore" # once changed, this is no longer tracked by TF. See secrets.ops.pardot.com for latest PW
  parameter_group_name = "default.postgres9.5"

  vpc_security_group_ids = [
    "${aws_security_group.q3_secgroup.id}",
  ]
}

resource "aws_security_group" "q3_secgroup" {
  description = "q3_secgroup"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"

    cidr_blocks = [
      "${var.jump_dot_dev_ip_address}/32",
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
    Name      = "q3_secgroup"
    terraform = "true"
  }
}
