resource "aws_route53_record" "e2ecredentials_dev_pardot_com_CNAMErecord" {
  zone_id = "${var.aws_route53_zone_dev_pardot_com_zone_id}"
  name    = "e2ecredentials.dev.pardot.com"
  records = ["pardot-e2e-credentials.herokuapp.com/"]
  type    = "CNAME"
  ttl     = "900"
}
