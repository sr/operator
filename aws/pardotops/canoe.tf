resource "aws_ecr_repository" "canoe" {
  name = "canoe"
}

resource "aws_iam_role" "canoe_ec2_role" {
  name = "canoe_ec2_role"
  assume_role_policy = "${file(\"ec2_instance_trust_relationship.json\")}"
}

resource "aws_iam_instance_profile" "canoe_ec2_instance_profile" {
  name = "canoe_ec2_instance_profile"
  roles = ["${aws_iam_role.canoe_ec2_role.name}"]
}
