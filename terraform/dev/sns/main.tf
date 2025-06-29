terraform {
  backend "s3" {
    bucket         = "terraform-state-security-web-waf"
    dynamodb_table = "terraform-state-security-web-waf"
    encrypt        = true
    key            = "dev-sns.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "sns_dev_alerts" {
  source = "../../modules/sns"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  topic_name = "udemy-dev-alerts"

  subscriptions = {
    sergii = {
      protocol = "email"
      endpoint = "{put_your_email_here}"
    },
  }
}
