resource "aws_ecs_cluster" "parbot_production" {
  name = "parbot_production"
}

data "template_file" "parbot_production_user_data" {
  template = "${file("ecs_user_data.tpl")}"

  vars {
    configuration_environment = "production"
    ecs_cluster               = "parbot_production"
  }
}

resource "aws_security_group" "parbot_app_production" {
  name   = "parbot_app_production"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.pardot0_ue1_bastion.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "parbot_production" {
  name_prefix                 = "parbot_production"
  image_id                    = "${var.ecs_ami_id}"
  instance_type               = "t2.small"
  key_name                    = "internal_apps"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  security_groups             = ["${aws_security_group.parbot_app_production.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.parbot_production_user_data.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "parbot_production" {
  max_size             = 1
  min_size             = 1
  launch_configuration = "${aws_launch_configuration.parbot_production.id}"

  vpc_zone_identifier = [
    "${aws_subnet.pardot0_ue1_1a.id}",
    "${aws_subnet.pardot0_ue1_1c.id}",
    "${aws_subnet.pardot0_ue1_1d.id}",
    "${aws_subnet.pardot0_ue1_1e.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_subnet_group" "parbot_production" {
  name        = "parbot-production"
  description = "parbot production"

  subnet_ids = [
    "${aws_subnet.pardot0_ue1_1a.id}",
    "${aws_subnet.pardot0_ue1_1c.id}",
    "${aws_subnet.pardot0_ue1_1d.id}",
    "${aws_subnet.pardot0_ue1_1e.id}",
  ]
}

resource "aws_security_group" "parbot_redis_production" {
  name   = "parbot_redis_production"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.parbot_app_production.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "parbot_production" {
  cluster_id               = "parbot-production"
  engine                   = "redis"
  engine_version           = "2.8.24"
  maintenance_window       = "Tue:00:00-Tue:04:00"
  node_type                = "cache.m3.medium"
  num_cache_nodes          = 1
  parameter_group_name     = "default.redis2.8"
  port                     = 6379
  subnet_group_name        = "${aws_elasticache_subnet_group.parbot_production.name}"
  security_group_ids       = ["${aws_security_group.parbot_redis_production.id}"]
  snapshot_retention_limit = 30
  snapshot_window          = "04:00-06:00"
}

resource "aws_security_group" "parbot_db_production" {
  name   = "parbot_db_production"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.parbot_app_production.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "parbot_production" {
  identifier              = "parbot-production"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "5.6.23"
  instance_class          = "db.t2.small"
  storage_type            = "standard"
  name                    = "parbot_production"
  username                = "parbot"
  password                = "eixaibi8Mepuenom8aoH9Ahh9Fooj5foma0cohge"
  maintenance_window      = "Tue:00:00-Tue:04:00"
  multi_az                = true
  publicly_accessible     = false
  db_subnet_group_name    = "${aws_db_subnet_group.pardot0_ue1.name}"
  vpc_security_group_ids  = ["${aws_security_group.parbot_db_production.id}"]
  storage_encrypted       = false
  backup_retention_period = 5
  apply_immediately       = true
}
