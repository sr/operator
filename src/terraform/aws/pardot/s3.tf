resource "aws_s3_bucket" "pdo" {
  bucket = "pardot-pdo"
  acl = "bucket-owner-full-control"
}
