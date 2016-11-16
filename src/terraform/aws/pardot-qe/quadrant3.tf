resource "aws_db_instance" "q3db" {
  allocated_storage    = 50
  engine               = "postgres"
  instance_class       = "db.t1.micro"
  name                 = "mydb"
  username             = "pardottandp"
  password             = "thisIsNotThePasswordAnymore" # once changed, this is no longer tracked by TF. See secrets.ops.pardot.com for latest PW
  parameter_group_name = "default.mysql5.6"

  vpc_security_group_ids = [
    "${aws_security_group.q3_secgroup.id}",
  ]
}

resource "aws_security_group" "q3_secgroup" {
  description = "q3_secgroup"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "mysql"

    cidr_blocks = [
      "${var.jump_dot_dev_ip_address}",
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
