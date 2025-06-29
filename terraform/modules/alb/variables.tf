variable "main_domain" {
  description = "The main for ACM cert"
  type        = string
}

variable "vpc" {}

variable "lb_sg" {
  description = "The ALB security group"
}

variable "lb_subnets" {}

variable "logs_enabled" {
  description = "ALB app logging enabled"
  type        = bool
}

variable "logs_prefix" {
  description = "The ALB app logs prefix"
  type        = string
}

variable "logs_bucket" {
  type        = string
  description = "ALB Logs bucket name"
  default     = null
}

variable "logs_expiration" {
  type        = number
  description = "ALB Logs expiration (S3)"
}

variable "logs_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "Force terraform destruction of the ALB Logs bucket?"
}

variable "lb_ssl_policy" {
  description = "The ALB ssl policy"
  type        = string
}

variable "create_aliases" {
  type        = list(map(string))
  description = "List of DNS Aliases to create pointing at the ALB"
}

# WAF

variable "waf_secret_header_value" {
  type        = string
  description = "Value of secret header for detecting by WAF that requests come from within company backend apps"
}

variable "waf_rules_override_action" {
  description = "Two options: 'none' - rules are active, 'count' - they are only counted and requests are always passed on"
  default     = "none"
}

variable "custom_waf_rules" {
  type        = bool
  description = "True if custom waf should be enabled"
  default     = true
}

variable "rate_subdomain_rules" {
  type = list(object({
    subdomain = string
    action    = string
    limit     = number
    name      = string
    priority  = number
  }))

  default = [
    {
      name      = "rate-subdomain-flask"
      subdomain = "flask.sergiitest.website"
      action    = "block"
      limit     = 100
      priority  = 3
    }
  ]
}

variable "rate_url_rules" {
  type = list(object({
    action                = string
    limit                 = number
    metric_name           = string
    name                  = string
    positional_constraint = string
    priority              = number
    search_string         = string
  }))

  default = [
    {
      action                = "block"
      limit                 = 100
      metric_name           = "rate-api-all"
      name                  = "rate-api-all"
      positional_constraint = "CONTAINS"
      search_string         = "test"
      priority              = 4
    },
  ]
}

variable "rate_url_rules_with_or" {
  type = list(object({
    action        = string
    limit         = number
    metric_name   = string
    name          = string
    or_statements = list(map(string))
    priority      = number
  }))

  default = [
    {
      action      = "block"
      limit       = 100
      metric_name = "rate-or-condition-example"
      name        = "rate-or-condition-example"
      priority    = 5
      or_statements = [
        {
          positional_constraint = "STARTS_WITH"
          search_string         = "test"
        },
        {
          positional_constraint = "CONTAINS"
          search_string         = "favicon"
        }
      ]
    },
  ]
}

variable "managed_rules" {
  type = list(object({
    name           = string
    priority       = number
    version        = string
    limit          = number
    excluded_rules = list(string)
    blocking_rules = list(string)
  }))

  description = "List of AWS Managed WAFv2 rules"

  default = [
    {
      name           = "AWSManagedRulesAmazonIpReputationList"
      priority       = 6
      version        = null
      limit          = 1
      excluded_rules = []
      blocking_rules = [
        "AWSManagedIPReputationList",
        "AWSManagedReconnaissanceList",
        "AWSManagedIPDDoSList"
      ]
    },
    {
      name           = "AWSManagedRulesCommonRuleSet"
      priority       = 7
      version        = "Version_1.10"
      limit          = 1
      excluded_rules = [
        "NoUserAgent_HEADER",
        "UserAgent_BadBots_HEADER",
        "SizeRestrictions_BODY",
      ]
      blocking_rules = [
        "SizeRestrictions_URIPATH",
        "GenericLFI_URIPATH",
        "SizeRestrictions_QUERYSTRING",
        "SizeRestrictions_Cookie_HEADER",
        "EC2MetaDataSSRF_BODY",
        "EC2MetaDataSSRF_COOKIE",
        "EC2MetaDataSSRF_URIPATH",
        "EC2MetaDataSSRF_QUERYARGUMENTS",
        "GenericLFI_QUERYARGUMENTS",
        "GenericLFI_BODY",
        "RestrictedExtensions_URIPATH",
        "RestrictedExtensions_QUERYARGUMENTS",
        "GenericRFI_QUERYARGUMENTS",
        "GenericRFI_BODY",
        "GenericRFI_URIPATH",
        "CrossSiteScripting_COOKIE",
        "CrossSiteScripting_QUERYARGUMENTS",
        "CrossSiteScripting_BODY",
        "CrossSiteScripting_URIPATH"
      ]
    },
    {
      name           = "AWSManagedRulesLinuxRuleSet"
      priority       = 8
      version        = "Version_2.2"
      limit          = 1
      excluded_rules = []
      blocking_rules = [
        "LFI_URIPATH",
        "LFI_QUERYSTRING",
        "LFI_HEADER"
      ]
    },
    {
      name           = "AWSManagedRulesSQLiRuleSet"
      priority       = 9
      version        = "Version_1.1"
      limit          = 1
      excluded_rules = [
        "SQLi_COOKIE"
      ]
      blocking_rules = [
        "SQLiExtendedPatterns_QUERYARGUMENTS",
        "SQLi_QUERYARGUMENTS",
        "SQLi_BODY",
        "SQLi_URIPATH"
      ]
    }
  ]
}

variable "ips_to_be_allowed" {
  description = "The list of IPs from EC2s to be allowed in WAF"
  type        = list(string)
  default     = []
}

variable "alarm_sns_topic_name" {
  type = string
}

variable "alb_5xx_threshold" {
  type    = number
  default = 20
}

variable "target_5xx_threshold" {
  type    = number
  default = 20
}