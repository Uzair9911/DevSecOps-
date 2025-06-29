resource "aws_cloudwatch_metric_alarm" "authentication-errors" {
  alarm_name                = "${local.app_name_full}-authentication-error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "${local.app_name_full}-authentication-error"
  namespace                 = "Application Logs"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "10"
  insufficient_data_actions = []
  alarm_actions             = [data.aws_sns_topic.alarm_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "bad-request-errors" {
  alarm_name                = "${local.app_name_full}-bad-request-error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "${local.app_name_full}-bad-request-error"
  namespace                 = "Application Logs"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "10"
  insufficient_data_actions = []
  alarm_actions             = [data.aws_sns_topic.alarm_topic.arn]

}

resource "aws_cloudwatch_metric_alarm" "not-found-errors" {
  alarm_name                = "${local.app_name_full}-not-found-error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "${local.app_name_full}-not-found-error"
  namespace                 = "Application Logs"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "10"
  insufficient_data_actions = []
  alarm_actions             = [data.aws_sns_topic.alarm_topic.arn]

}

resource "aws_cloudwatch_metric_alarm" "critical-errors" {
  alarm_name                = "${local.app_name_full}-critical-error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "${local.app_name_full}-critical-error"
  namespace                 = "Application Logs"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "10"
  insufficient_data_actions = []
  alarm_actions             = [data.aws_sns_topic.alarm_topic.arn]

}
