data "aws_acm_certificate" "main" {
  domain      = var.main_domain
  statuses    = ["ISSUED"]
  most_recent = true
}
