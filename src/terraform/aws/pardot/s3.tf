resource "aws_s3_bucket" "pardot_pdo" {
  bucket = "pardot-pdo"
  acl    = "private"
}

# And the associated bucket used for dev & testing
resource "aws_s3_bucket" "pardot_pdo_dev" {
  bucket = "pardot-pdo-dev"
  acl    = "private"
}
