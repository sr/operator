resource "aws_s3_bucket" "pardotops_configuration" {
  bucket = "pardotops-configuration"
  acl    = "private"

  versioning {
    enabled = true
  }
}
