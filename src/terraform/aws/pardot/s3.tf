resource "aws_s3_bucket" "pdo" {
    bucket = "pdo"
    acl = "bucket-owner-full-control"
}
