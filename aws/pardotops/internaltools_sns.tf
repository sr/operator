/* define SNS email endpoints */
variable "internal-alert-email-endpoints" {
  type = "map"
  default = {
    non-paging = "pd-bread+internaltoolsalerts@salesforce.com"
    paging = "bread@pardot.pagerduty.com"
  }
}

/* establish the topic */
resource "aws_sns_topic" "internaltools" {
  name = "internaltools"
  display_name = "IntTools" /* has a 10 char limit for some reason */
}

/* sub to the topic; pick paging or non-paging */
resource "aws_sns_topic_subscription" "internaltools-scrip" {
  topic_arn = "${aws_sns_topic.internaltools.arn}"
  protocol  = "email"
  endpoint  = "${var.internal-alert-email-endpoints.non-paging}"
}

/* define ASG event based notifiers */
resource "aws_autoscaling_notification" "internaltools-asg-notification" {
  group_names = [
    "${aws_autoscaling_group.canoe_production.name}",
    "${aws_autoscaling_group.hal9000_production.name}"
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = "${aws_sns_topic.internaltools.arn}"
}