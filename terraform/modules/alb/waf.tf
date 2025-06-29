resource "aws_wafv2_web_acl" "aws_managed_webacl" {
  name        = "${local.name_prefix}-webacl-apps"
  description = "WAFv2 AWS Managed Rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "${local.name_prefix}-ips-to-be-allowed"
    priority = 0

    action {
      allow {}
    }

    statement {
      and_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.ips_from_servers_to_be_allowed.arn
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = var.waf_secret_header_value

            text_transformation {
              priority = 0
              type     = "NONE"
            }

            field_to_match {
              single_header {
                name = "waf-secret"
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-ips-to-be-allowed"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "${local.name_prefix}-ips-to-be-blocked"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ips_to_be_blocked.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-ips-to-be-blocked"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "${local.name_prefix}-xss-cookie-allow"
    priority = 2

    action {
      allow {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.xss_cookie.arn

        field_to_match {
          single_header {
            name = "cookie"
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-xss-alb-allow"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.rate_subdomain_rules

    content {
      name     = format("%s-%s", local.name_prefix, rule.value.name)
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          aggregate_key_type = "IP"
          limit              = rule.value.limit

          scope_down_statement {
            byte_match_statement {

              positional_constraint = "STARTS_WITH"
              search_string         = rule.value.subdomain

              field_to_match {
                single_header {
                  name = "host"
                }
              }

              text_transformation {
                priority = 0
                type     = "LOWERCASE"
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.rate_url_rules

    content {
      name     = format("%s-%s", local.name_prefix, rule.value.name)
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          aggregate_key_type = "IP"
          limit              = rule.value.limit
          scope_down_statement {
            byte_match_statement {
              positional_constraint = rule.value.positional_constraint
              search_string         = rule.value.search_string
              field_to_match {
                uri_path {}
              }
              text_transformation {
                priority = 0
                type     = "NONE"
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.rate_url_rules_with_or

    content {
      name     = format("%s-%s", local.name_prefix, rule.value.name)
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          aggregate_key_type = "IP"
          limit              = rule.value.limit
          scope_down_statement {
            or_statement {
              dynamic "statement" {
                for_each = rule.value.or_statements
                content {
                  byte_match_statement {
                    positional_constraint = statement.value.positional_constraint
                    search_string         = statement.value.search_string
                    field_to_match {
                      uri_path {}
                    }
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.managed_rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = var.waf_rules_override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = var.waf_rules_override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          version     = rule.value.version
          vendor_name = "AWS"

          dynamic "rule_action_override" {
            for_each = rule.value.blocking_rules
            content {
              name = rule_action_override.value
              action_to_use {
                block {}
              }
            }
          }

          dynamic "rule_action_override" {
            for_each = rule.value.excluded_rules
            content {
              name = rule_action_override.value
              action_to_use {
                count {}
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${local.name_prefix}-webacl"
  }

  tags = local.common_tags
}

resource "aws_wafv2_ip_set" "ips_to_be_blocked" {
  name               = "ips-to-be-blocked"
  description        = "IPs to be blocked"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = []

  tags = local.common_tags

  lifecycle {
    ignore_changes = [addresses]
  }
}

resource "aws_wafv2_ip_set" "ips_from_servers_to_be_allowed" {
  name               = "ips-from-servers-to-be-allowed"
  description        = "IPs from servers to be allowed"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ips_to_be_allowed
}

resource "aws_wafv2_regex_pattern_set" "xss_cookie" {
  name        = "xss_cookie"
  description = "Custom pattern for app cookies to be allowed"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "MYAPP.*=.*((?i)on.*=(?-i)).+"
  }
}

resource "aws_s3_bucket" "waf_logs" {
  bucket = "aws-waf-logs-${local.name_prefix}-apps"

  acl = "private"

  lifecycle_rule {
    id      = "delete"
    enabled = true

    expiration {
      days = 30
    }
  }

  force_destroy = false
  tags          = local.common_tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "log_configuration" {
  log_destination_configs = [aws_s3_bucket.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.aws_managed_webacl.arn
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.aws_managed_webacl.arn
}
