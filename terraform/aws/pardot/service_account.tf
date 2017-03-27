resource "aws_iam_user" "pardot_sysacct" {
  name = "sa_pardot"
}

resource "aws_iam_user_policy" "pardot_sysacct_access_rights" {
  name = "PardotServerSysAcctPolicy"
  user = "${aws_iam_user.pardot_sysacct.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket",
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.pardot_pdo.bucket}"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:PutObjectAcl",
              "s3:PutObjectVersionAcl",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.pardot_pdo.bucket}/*"
          ]
      }
  ]
}
EOF
}

resource "aws_iam_user" "pardot_sysacct_dev" {
  name = "sa_pardot_dev"
}

resource "aws_iam_user_policy" "pardot_sysacct_dev_access_rights" {
  name = "PardotServerSysAcctDevPolicy"
  user = "${aws_iam_user.pardot_sysacct_dev.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket",
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.pardot_pdo_dev.bucket}"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:PutObjectAcl",
              "s3:PutObjectVersionAcl",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.pardot_pdo_dev.bucket}/*"
          ]
      }
  ]
}
EOF
}
