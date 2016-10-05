
resource "aws_db_instance" "providence_production" {
  identifier = "providence-production"
  allocated_storage = 20
  engine = "postgresql"
  engine_version = "9.5.4"
  instance_class = "db.t2.small"
  storage_type = "standard"
  name = "providence_production"
  username = "providence"
  password = "###REDACTED###"
  maintenance_window = "Tue:00:00-Tue:04:00"
  multi_az = true
  publicly_accessible = false
  db_subnet_group_name = "${aws_db_subnet_group.internal_apps.name}"
  vpc_security_group_ids = ["${aws_security_group.providence_db_production.id}"]
  storage_encrypted = false
  backup_retention_period = 30
  apply_immediately = true
}

resource "aws_security_group" "providence_db_production" {
  name = "providence_db_production"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.internal_apps_providence_server.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_apps_providence_server" {
  name = "internal_apps_providence_server"
  description = "Providence Server for the AWS environment"
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

resource "aws_instance" "internal_apps_providence_server" {
  ami = "${var.centos_7_hvm_ebs_ami}"
  instance_type = "t2.medium"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a.id}"
  vpc_security_group_ids = [
    "${aws_security_group.internal_apps_providence_server.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-providence1-1-ue1"
    terraform = true
  }
}

resource "aws_route53_record" "internal_apps_providence1-1_Arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name = "pardot0-providence1-1-ue1.aws.pardot.com"
  records = ["${aws_instance.internal_apps_providence_server.private_ip}"]
  type = "A"
  ttl = "900"
}
