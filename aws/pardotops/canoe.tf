resource "aws_ecr_repository" "canoe" {
  name = "canoe"
}

resource "aws_iam_role" "canoe_ec2_role" {
  name = "canoe_ec2_role"
  assume_role_policy = "${file(\"ec2_instance_trust_relationship.json\")}"
}

resource "aws_iam_role_policy" "canoe_ec2_ecs_service_policy" {
  name = "canoe_ec2_ecs_service_policy"
  role = "${aws_iam_role.canoe_ec2_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "canoe_ec2_instance_profile" {
  name = "canoe_ec2_instance_profile"
  roles = ["${aws_iam_role.canoe_ec2_role.name}"]
}

resource "aws_ecs_cluster" "canoe_production" {
  name = "canoe_production"
}
