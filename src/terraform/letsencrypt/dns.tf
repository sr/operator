resource "aws_route53_record" "e2ecredentials_dev_pardot_com_CNAMErecord" {
  zone_id = "${var.aws_route53_zone_dev_pardot_com_zone_id}"
  name    = "${tls_cert_request.e2ec_dev_pardot_com.subject.common_name}"
  records = ["pardot-e2e-credentials.herokuapp.com"]
  type    = "CNAME"
  ttl     = "900"
}
