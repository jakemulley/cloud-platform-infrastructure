
terraform {
  backend "s3" {
    bucket         = "cloud-platform-ephemeral-test-tfstate"
    region         = "eu-west-2"
    key            = "global-resources/iam/terraform.tfstate"
    dynamodb_table = "cloud-platform-ephemeral-test-tfstate"
    encrypt        = true
  }
}

###########################
# Security Baseguidelines #
###########################

module "baselines" {
  #source = "github.com/ministryofjustice/cloud-platform-terraform-awsaccounts-iam?ref=0.0.1"
  source = "/Users/mogaal/workspace/github/ministryofjustice/cloud-platform-terraform-awsaccounts-baselines"

  account_name  = "cloud-platform-ephemeral-test"
  region        = "eu-west-2"
  slack_webhook = var.baselines_alerts_slack_webhook
  slack_channel = var.baselines_alerts_slack_channel
}

#######
# IAM #
#######

module "iam" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-awsaccounts-iam?ref=0.0.1"

  aws_account_name = "cloud-platform-ephemeral-test"
}

#######
# DNS #
#######

# Nothing yet

# new parent DNS zone for clusters
resource "aws_route53_zone" "root_aws_account_cloudplatform_justice_gov_uk" {
  name     = "ephemeral-test.cloud-platform.service.justice.gov.uk."
}

