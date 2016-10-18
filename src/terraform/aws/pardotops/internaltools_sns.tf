variable "internal_alert_email_endpoints" {
  type = "map"

  default = {
    non_paging = "pd-bread+internaltoolsalerts@salesforce.com"
    paging     = "bread@pardot.pagerduty.com"
  }
}

resource "aws_sns_topic" "internaltools" {
  name         = "internaltools"
  display_name = "IntTools"
}

resource "aws_autoscaling_notification" "internaltools_asg_events_notifier" {
  group_names = [
    "${aws_autoscaling_group.canoe_production.name}",
    "${aws_autoscaling_group.operator_production.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.internaltools.arn}"
}
