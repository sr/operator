/* define SNS email endpoints */
variable "internal_alert_email_endpoints" {
  type = "map"

  default = {
    non_paging = "pd-bread+internaltoolsalerts@salesforce.com"
    paging     = "bread@pardot.pagerduty.com"
  }
}

/* establish the topic */
resource "aws_sns_topic" "internaltools" {
  name         = "internaltools"
  display_name = "IntTools"      /* has a 10 char limit for some reason */
}

/* sub to the topic; pick paging or non_paging */

/* !! 'email' protocol NOT CURRENTLY SUPPORTED IN TERRAFORM! :( !!  */

/* resource "aws_sns_topic_subscription" "internaltools_scrip" {
  topic_arn = "${aws_sns_topic.internaltools.arn}"
  protocol  = "email"
  endpoint  = "${var.internal_alert_email_endpoints.non_paging}"
} */

/* define ASG event based notifiers */
resource "aws_autoscaling_notification" "internaltools_asg_events_notifier" {
  group_names = [
    "${aws_autoscaling_group.canoe_production.name}",
    "${aws_autoscaling_group.hal9000_production.name}",
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
