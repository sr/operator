resource "aws_route53_zone" "pardot_ci_aws_pardot_com_hosted_zone" {
  name    = "aws.pardot.com"
  comment = "Managed by Terraform. Private DNS for VPC: ${aws_vpc.pardot_ci.id} Only. Hosted solely in AWS."
  vpc_id  = "${aws_vpc.pardot_ci.id}"
}

resource "aws_route53_record" "pardot2_auth1_1_ue1_Arecord" {
  zone_id = "${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot2-auth1-1-ue1.${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.name}"
  records = ["${var.pardot2-auth1-1-ue1_aws_pardot_com_private_ip}"]
  ttl     = "900"
  type    = "A"
}

resource "aws_route53_record" "pardot2_chef1_1_ue1_Arecord" {
  zone_id = "${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot2-chef1-1-ue1.${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.name}"
  records = ["${var.pardot2-chef1-1-ue1_aws_pardot_com_private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "pardot2_bastion1_1_ue1_Arecord" {
  zone_id = "${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot2-bastion1-1-ue1.${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.name}"
  records = ["${var.pardot2-bastion1-1-ue1_aws_pardot_com_private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "docker_cache_aws_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.zone_id}"
  name    = "docker-cache.${aws_route53_zone.pardot_ci_aws_pardot_com_hosted_zone.name}"
  records = ["${var.pardot0_artifactcache_elb_public_dns}"]
  type    = "CNAME"
  ttl     = "900"
}
