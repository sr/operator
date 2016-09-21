// NOTE:
// THIS IS NOT APPDEV'S FACILITIES -- THIS IS FOR DEVELOPER LOCAL-ENVIRONMENT TESTING ONLY! THIS IS PURELY A SANDBOX.
// SEE: BREAD-1212 / PDT-25747

resource "aws_iam_user" "pithumbs_public_sandbox_service_acct" {
   name = "sa_thumbs_public_sandbox"
}

resource "aws_s3_bucket" "pithumbs_public_sandbox_s3_filestore" {
  bucket = "pithumbs_public_sandbox"
  acl = "public-read"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "allow pithumbs sysacct",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.pithumbs_public_sandbox_service_acct.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::pithumbs_public_sandbox",
        "arn:aws:s3:::pithumbs_public_sandbox/*"
      ]
    },
    {
	  "Sid": "PublicRead",
	  "Effect": "Allow",
	  "Principal": {
	    "AWS": "*"
	  },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::pithumbs_public_sandbox/*"
    }
  ]
}
EOF
  tags {
    Name = "pithumbs_public_sandbox"
    terraform = "true"
  }
}