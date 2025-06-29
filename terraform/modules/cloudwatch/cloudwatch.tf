resource "aws_cloudwatch_log_group" "flask" {
  name              = local.app_name_full
  retention_in_days = "90"
}

resource "aws_cloudwatch_log_metric_filter" "authentication-error" {
  name           = "${local.app_name_full}-authentication-error"
  pattern        = "Authentication Error"
  log_group_name = aws_cloudwatch_log_group.flask.name

  metric_transformation {
    name          = "${local.app_name_full}-authentication-error"
    namespace     = "Application Logs"
    value         = "1"
    unit          = "Count"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "bad-request-error" {
  name           = "${local.app_name_full}-bad-request-error"
  pattern        = "Bad Request Error"
  log_group_name = aws_cloudwatch_log_group.flask.name

  metric_transformation {
    name          = "${local.app_name_full}-bad-request-error"
    namespace     = "Application Logs"
    value         = "1"
    unit          = "Count"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "not-found-error" {
  name           = "${local.app_name_full}-not-found-error"
  pattern        = "NotFound Error"
  log_group_name = aws_cloudwatch_log_group.flask.name

  metric_transformation {
    name          = "${local.app_name_full}-not-found-error"
    namespace     = "Application Logs"
    value         = "1"
    unit          = "Count"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "critical-error" {
  name           = "${local.app_name_full}-critical-error"
  pattern        = "Critical Error"
  log_group_name = aws_cloudwatch_log_group.flask.name

  metric_transformation {
    name          = "${local.app_name_full}-critical-error"
    namespace     = "Application Logs"
    value         = "1"
    unit          = "Count"
    default_value = "0"
  }
}
