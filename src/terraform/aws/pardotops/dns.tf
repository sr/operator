resource "aws_route53_zone" "dev_pardot_com" {
  name    = "dev.pardot.com"
  comment = "Managed by Terraform. Subdomain of pardot.com hosted in Dyn."
}

resource "aws_route53_zone" "ops_pardot_com" {
  name    = "ops.pardot.com"
  comment = "Managed by Terraform. Subdomain of pardot.com hosted in Dyn."
}

resource "aws_route53_zone" "aws_pardot_com_restricted_use_public_zone" {
  name    = "aws.pardot.com"
  comment = "This is the public face of aws.pardot.com, and it should be used as VERY LITTLE as possible. Seek BREAD approval before use!"
}

resource "aws_route53_record" "awstools_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "awstools.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.70.118.212"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "bamboo_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "bamboo.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.51.79"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "bamboo_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "bamboo.${aws_route53_zone.dev_pardot_com.name}"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "amazonses_bamboo_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "_amazonses.bamboo.${aws_route53_zone.dev_pardot_com.name}"
  records = ["iikqS8gW4E1ceNzqQqTyLCxvuY1MZb5+kJZp/fqvxB8="]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "amazonses_confluence_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "_amazonses.confluence.${aws_route53_zone.dev_pardot_com.name}"
  records = ["lDTrhfHFMA7gXvE8VeZU4rdqeGCzej85PAu90elY5KI="]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "3y57xkxsmwsmtqkf25zl6hzldkxqdegs_domainkey_bamboo_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "3y57xkxsmwsmtqkf25zl6hzldkxqdegs._domainkey.bamboo.${aws_route53_zone.dev_pardot_com.name}"
  records = ["3y57xkxsmwsmtqkf25zl6hzldkxqdegs.dkim.amazonses.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "2fdyawtj4aey2pyxj74c7o3wvx6zb62w_domainkey_bamboo_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "2fdyawtj4aey2pyxj74c7o3wvx6zb62w._domainkey.bamboo.${aws_route53_zone.dev_pardot_com.name}"
  records = ["2fdyawtj4aey2pyxj74c7o3wvx6zb62w.dkim.amazonses.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "e7l7trjgcjj66i2b4ja3yughhara3sum_domainkey_bamboo_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "e7l7trjgcjj66i2b4ja3yughhara3sum._domainkey.bamboo.${aws_route53_zone.dev_pardot_com.name}"
  records = ["e7l7trjgcjj66i2b4ja3yughhara3sum.dkim.amazonses.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "bots_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "bots.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.199.236"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "canoe_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "canoe.${aws_route53_zone.dev_pardot_com.name}"
  records = ["canoe-production-182149789.us-east-1.elb.amazonaws.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "canoe-dfw_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "canoe-dfw.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-dfw.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "canoe-phx_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "canoe-phx.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-phx.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "chef_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "chef.${aws_route53_zone.dev_pardot_com.name}"
  records = ["66.228.122.194"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "confluence_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "confluence.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.52.103"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "quadrant3_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "quadrant3.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${var.quadrant3_test_host_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "confluence_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "confluence.${aws_route53_zone.dev_pardot_com.name}"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "crowd_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "crowd.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.42.123"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "crowd_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "crowd.${aws_route53_zone.dev_pardot_com.name}"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "docker_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "docker.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_elb.external_artifact_cache_lb.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "docker-origin_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "docker-origin.${aws_route53_zone.dev_pardot_com.name}"
  records = ["artifactory-origin.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "docker-internal_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "docker-internal.${aws_route53_zone.dev_pardot_com.name}"
  records = ["artifactory-internal.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "git_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "git.${aws_route53_zone.dev_pardot_com.name}"
  records = ["1.git.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "60"
}

resource "aws_route53_record" "git-internal_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "git-internal.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_instance.github_enterprise_server_1.private_ip}"]
  type    = "A"
  ttl     = "60"
}

resource "aws_route53_record" "1_git_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "1.git.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_instance.github_enterprise_server_1.public_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "2_git_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "2.git.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_instance.github_enterprise_server_2.public_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "reply_git_dev_pardot_com_MXrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "reply.git.${aws_route53_zone.dev_pardot_com.name}"
  records = ["10 git.dev.pardot.com."]
  type    = "MX"
  ttl     = "900"
}

resource "aws_route53_record" "go_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "go.${aws_route53_zone.dev_pardot_com.name}"
  records = ["app.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "grafana-dfw_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "grafana-dfw.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-dfw.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "grafana-phx_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "grafana-phx.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-phx.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "graphite-dfw_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "graphite-dfw.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-dfw.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "graphite-phx_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "graphite-phx.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-phx.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "hal9000_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "hal9000.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_alb.operator_production.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "operator_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "operator.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_alb.operator_production.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "events_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "events.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_alb.operator_production.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "bread_sentry_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "bread-sentry.${aws_route53_zone.dev_pardot_com.name}"
  records = ["evening-gorge-8439.whispering-wildwood-3486.herokuspace.com"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "crammer_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "crammer.${aws_route53_zone.dev_pardot_com.name}"
  records = ["guarded-journey-4135.whispering-wildwood-3486.herokuspace.com"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "compliance_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "compliance.${aws_route53_zone.dev_pardot_com.name}"
  records = ["secure-ravine-3371.whispering-wildwood-3486.herokuspace.com"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "hipchat_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "hipchat.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.35.223"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "hipchat_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "hipchat.${aws_route53_zone.dev_pardot_com.name}"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "id_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "id.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.8.208.137"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "jira_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "jira.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.34.28"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "jira_dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "jira.${aws_route53_zone.dev_pardot_com.name}"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "jobs_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "jobs.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.5.130.6"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "storm_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "storm.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.appdev_toolsproxy1.public_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "rundeck_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "rundeck.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.appdev_toolsproxy1.public_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "jump_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "jump.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.appdev_bastion_eip.public_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "ldap_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "ldap.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.216.152"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "logs-dfw_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "logs-dfw.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-dfw.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "logs-phx_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "logs-phx.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-phx.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "migration_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "migration.${aws_route53_zone.dev_pardot_com.name}"
  records = ["174.37.191.2"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "pandafood_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "pandafood.${aws_route53_zone.dev_pardot_com.name}"
  records = ["ec2-52-70-118-212.compute-1.amazonaws.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "pd-zbx-pxy_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "pd-zbx-pxy.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.237.0"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "preview_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "preview.${aws_route53_zone.dev_pardot_com.name}"
  records = ["app.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "push_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "push.${aws_route53_zone.dev_pardot_com.name}"
  records = ["174.37.191.4", "174.37.191.5"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "qetunnel_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "qetunnel.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.0.121.112"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "rabbit_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "rabbit.${aws_route53_zone.dev_pardot_com.name}"
  records = ["174.37.191.2"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "seyren_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "seyren.${aws_route53_zone.dev_pardot_com.name}"
  records = ["jump.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "stash_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "stash.${aws_route53_zone.dev_pardot_com.name}"
  records = ["52.5.210.41"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "tools-dfw_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "tools-dfw.${aws_route53_zone.dev_pardot_com.name}"
  records = ["136.147.104.46"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "tools-phx_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "tools-phx.${aws_route53_zone.dev_pardot_com.name}"
  records = ["136.147.96.46"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "zabbix-dfw_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "zabbix-dfw.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-dfw.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "zabbix-phx_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "zabbix-phx.${aws_route53_zone.dev_pardot_com.name}"
  records = ["tools-phx.dev.pardot.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "dev_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "dev.pardot.com"
  records = ["AvX35K2Ai6jcJ0TzFESkdw56z8AGQhKgTkGnmCc55j0="]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "_amazonses_aws_pardot_com_TXTrecord" {
  zone_id = "${aws_route53_zone.aws_pardot_com_restricted_use_public_zone.zone_id}"
  name    = "_amazonses.aws.pardot.com"
  records = ["9KokSQhsvoTH6kRsi7ZJeWvq1lqa6iPjZQjd+m9om9I="]
  type    = "TXT"
  ttl     = "900"
}

resource "aws_route53_record" "4vvsycwinukyxljj75npvs4n72ks43x4_domainkey_aws_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.aws_pardot_com_restricted_use_public_zone.zone_id}"
  name    = "4vvsycwinukyxljj75npvs4n72ks43x4._domainkey.aws.pardot.com"
  records = ["4vvsycwinukyxljj75npvs4n72ks43x4.dkim.amazonses.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "gwaulixbpldbwxydib3a6hqpss6xka7b_domainkey_aws_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.aws_pardot_com_restricted_use_public_zone.zone_id}"
  name    = "gwaulixbpldbwxydib3a6hqpss6xka7b._domainkey.aws.pardot.com"
  records = ["gwaulixbpldbwxydib3a6hqpss6xka7b.dkim.amazonses.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "if6ggapiro7g2s7udchcwj3hb2uujydn_domainkey_aws_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.aws_pardot_com_restricted_use_public_zone.zone_id}"
  name    = "if6ggapiro7g2s7udchcwj3hb2uujydn._domainkey.aws.pardot.com"
  records = ["if6ggapiro7g2s7udchcwj3hb2uujydn.dkim.amazonses.com."]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_route53_record" "aws_amazon_come_spf_TXTrecord" {
  zone_id = "${aws_route53_zone.aws_pardot_com_restricted_use_public_zone.zone_id}"
  name    = "aws.pardot.com"
  records = ["v=spf1 include:amazonses.com -all"]
  type    = "TXT"
  ttl     = "900"
}
