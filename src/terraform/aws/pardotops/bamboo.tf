resource "aws_iam_user" "sa_bamboo" {
  name = "sa_bamboo"
}

resource "aws_iam_user_policy" "sa_bamboo_ecs_deploy" {
  name = "sa_bamboo_ecs_deploy"
  user = "${aws_iam_user.sa_bamboo.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:List*",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
