output "sns_alarm_cloudwatch_topic_arn" {
  value = "${aws_sns_topic.sns_alarm_cloudwatch_topic.arn}"
}