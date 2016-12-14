resource "aws_vpc" "dev_environment" {
  cidr_block = "172.30.0.0/16"

  tags {
    Name = "dev_environment"
  }
}

resource "aws_security_group_rule" "dev_environment_allow_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_vpc.dev_environment.default_security_group_id}"

  cidr_blocks = [
    "${var.aloha_vpn_cidr_blocks}"
  ]
}

resource "aws_security_group_rule" "dev_environment_allow_vpn_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_vpc.dev_environment.default_security_group_id}"

  cidr_blocks = [
    "${var.aloha_vpn_cidr_blocks}"
  ]
}

resource "aws_security_group_rule" "dev_environment_allow_vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_vpc.dev_environment.default_security_group_id}"

  cidr_blocks = [
    "${var.aloha_vpn_cidr_blocks}"
  ]
}

resource "aws_security_group" "allow_inbound_http_https_from_sfdc" {
  name   = "allow_inbound_http_https_from_sfdc"
  vpc_id = "${aws_vpc.dev_environment.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# https://help.salesforce.com/apex/HTViewSolution?id=000003652
resource "aws_security_group_rule" "dev_environment_allow_salesforce_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.allow_inbound_http_https_from_sfdc.id}"

  cidr_blocks = [
    "13.108.0.0/14",
    "96.43.144.0/20",
    "136.146.0.0/15",
    "204.14.232.0/21",
  ]
}

# https://help.salesforce.com/apex/HTViewSolution?id=000003652
resource "aws_security_group_rule" "dev_environment_allow_salesforce_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.allow_inbound_http_https_from_sfdc.id}"

  cidr_blocks = [
    "13.108.0.0/14",
    "96.43.144.0/20",
    "136.146.0.0/15",
    "204.14.232.0/21",
  ]
}

resource "aws_subnet" "dev_environment_us_east_1b" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1b"
  cidr_block              = "172.30.0.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1c" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.30.32.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1d" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.30.64.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1e" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.30.96.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1b_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1b"
  cidr_block              = "172.30.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1c_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.30.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1d_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.30.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1e_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.30.224.0/19"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "dev_environment_internet_gw" {
  vpc_id = "${aws_vpc.dev_environment.id}"
}

resource "aws_eip" "dev_environment_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "dev_environment_nat_gw" {
  allocation_id = "${aws_eip.dev_environment_nat_gw.id}"
  subnet_id     = "${aws_subnet.dev_environment_us_east_1b_dmz.id}"
}

# All Artifactory requests get NATed so the source IP is constant
resource "aws_route" "dev_environment_artifactory_route" {
  route_table_id         = "${aws_vpc.dev_environment.main_route_table_id}"
  destination_cidr_block = "${var.legacy_artifactory_instance_ip}/32"       # artifactory.dev.pardot.com
  nat_gateway_id         = "${aws_nat_gateway.dev_environment_nat_gw.id}"
}

resource "aws_route" "dev_environment_internet_route" {
  route_table_id         = "${aws_vpc.dev_environment.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev_environment_internet_gw.id}"
}

resource "aws_route_table" "dev_environment_route_dmz" {
  vpc_id = "${aws_vpc.dev_environment.id}"
}

resource "aws_route" "dev_environment_dmz_internet_route" {
  route_table_id         = "${aws_route_table.dev_environment_route_dmz.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev_environment_internet_gw.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1b" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1b.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1c" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1c.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1d" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1d.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1e" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1e.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1b_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1b_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1c_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1d_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1e_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route53_zone" "pardot_local" {
  name   = "pardot.local"
  vpc_id = "${aws_vpc.dev_environment.id}"
}

resource "aws_route53_record" "star_pardot_local" {
  zone_id = "${aws_route53_zone.pardot_local.zone_id}"
  name    = "*.pardot.local"
  type    = "A"
  records = ["127.0.0.1"]
  ttl     = "3600"
}

resource "aws_db_instance" "oracle_sandbox_db" {
  allocated_storage       = 100
  engine                  = "oracle"
  engine_version          = "11.2.0.4.v1"
  instance_class          = "db.t2.small"
  name                    = "pardot_sandbox_db"
  port                    = 1521
  username                = "pardottandp"
  password                = "pardottandporaclesandbox" # WARNING: once changed, this is no longer tracked by TF
  parameter_group_name    = "default.oracle-ee-11.2"
  option_group_name       = "default:oracle-ee-11-2"
  character_set_name      = "AL32UTF8"
  storage_encrypted       = "false"
  maintenance_window      = "Sun:00:00-Sun:03:00"
  backup_retention_period = 14

  vpc_security_group_ids = [
    "${aws_security_group.oracle_sandbox_db_secgroup.id}",
  ]

  db_subnet_group_name = "${aws_db_subnet_group.oracle_sandbox_db_subnet_group.name}"
}

resource "aws_db_subnet_group" "oracle_sandbox_db_subnet_group" {
  name = "oracle_sandbox_db_subnet_group"

  subnet_ids = [
    "${aws_subnet.dev_environment_us_east_1c_dmz.id}",
    "${aws_subnet.dev_environment_us_east_1d_dmz.id}",
  ]
}

resource "aws_security_group" "oracle_sandbox_db_secgroup" {
  vpc_id      = "${aws_vpc.dev_environment.id}"
  name        = "oracle_sandbox_db_secgroup"
  description = "oracle_sandbox_db_secgroup"

  ingress {
    from_port = 1521
    to_port   = 1521
    protocol  = "TCP"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${aws_vpc.dev_environment.cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "oracle_sandbox_db_secgroup"
    terraform = "true"
  }
}

resource "aws_iam_role" "oracle_sandbox_db_access_role" {
  name               = "oracle_sandbox_db_access_role"
  assume_role_policy = "${aws_iam_policy.oracle_sandbox_db_access_role_policy.id}"
}

resource "aws_iam_policy" "oracle_sandbox_db_access_role_policy" {
  name = "oracle_sandbox_db_access_role"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"DenyOracleSandboxDeleteAccess",
         "Effect":"Deny",
         "Action":"rds:Delete*",
         "Resource":"${aws_db_instance.oracle_sandbox_db.arn}"
      },
      {
         "Sid":"AllowOracleSandboxAccess",
         "Effect":"Allow",
         "Action":"rds:*",
         "Resource":"${aws_db_instance.oracle_sandbox_db.arn}"
      }
   ]
}
EOF
}
