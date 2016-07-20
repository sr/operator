resource "aws_route53_zone" "dev_pardot_com" {
  name = "dev.pardot.com"
  comment = "Managed by Terraform. Subdomain of pardot.com hosted in Dyn."
}