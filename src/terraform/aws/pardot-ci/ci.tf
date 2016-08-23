resource "aws_iam_user" "bamboo_sysacct" {
  name = "bamboo_sysacct"
}

resource "aws_iam_user_policy" "bamboo_sysacct_access_rights" {
  name = "BambooServerSysAcct"
  user = "${aws_iam_user.bamboo_sysacct.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Sid": "AllowBambooToStartNewBuildAgents",
    "Effect": "Allow",
    "Action": [
      "ec2:Describe*",
      "ec2:RequestSpot*",
      "ec2:CancelSpot*",
      "ec2:CancelSpotInstanceRequests",
      "ec2:CreateKeyPair",
      "ec2:CreateTags",
      "ec2:RequestSpotInstances",
      "ec2:RunInstances"
    ],
    "Resource": "*"
  },
  {
    "Sid": "OnlyAllowBambooToAffectWhitelistedSubnets",
    "Effect": "Allow",
    "Action": [
      "ec2:ModifyInstanceAttribute",
      "ec2:GetConsoleOutput"
    ],
    "Resource": "*",
    "Condition": {
      "StringEquals": {
        "ec2:Vpc": "arn:aws:ec2:us-east-1:${var.pardot_ci_account_number}:vpc/${aws_vpc.pardot_ci.id}"
      }
    }
  },
  {
    "Sid": "OnlyAllowBambooToAffectWhitelistedVPCs",
    "Effect": "Allow",
    "Action": [
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress"
    ],
    "Resource": "*",
    "Condition": {
      "StringEquals": {
        "ec2:Subnet": "arn:aws:ec2:us-east-1:${var.pardot_ci_account_number}:vpc/${aws_subnet.pardot_ci_us_east_1c_dmz.id}"
      }
    }
  },
  {
    "Sid": "OnlyAllowBambooToTerminateBuildAgents",
    "Effect": "Allow",
    "Action": [
      "ec2:TerminateInstances",
      "ec2:StopInstances",
      "ec2:StartInstances"
    ],
    "Resource": "arn:aws:ec2:us-east-1:${var.pardot_ci_account_number}:instance/*",
    "Condition": {
      "StringEquals": {
        "ec2:ResourceTag/Name": "bam::pandafood.dev.pardot.com::root"
      }
    }
  }
  ]
}
EOF
}