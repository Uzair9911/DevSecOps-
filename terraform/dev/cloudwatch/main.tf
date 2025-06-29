terraform {
  backend "s3" {
    bucket         = "terraform-state-security-web-waf"
    dynamodb_table = "terraform-state-security-web-waf"
    encrypt        = true
    key            = "dev-cloudwatch.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  account_id           = var.account_id
  env                  = var.env
  project              = var.project
  region               = var.region
  log_streams          = [""]
  app_name             = "flask"
  alarm_sns_topic_name = "udemy-dev-alerts"
}
