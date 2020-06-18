
terraform {
  backend "s3" {
    bucket         = "cloud-platform-ephemeral-test-tfstate"
    region         = "eu-west-2"
    key            = "global-resources/terraform.tfstate"
    dynamodb_table = "cloud-platform-ephemeral-test-tfstate"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {}

###########################
# Security Baseguidelines #
###########################

# module "baselines" {
#   #source = "github.com/ministryofjustice/cloud-platform-terraform-awsaccounts-iam?ref=0.0.1"
#   source = "/Users/mogaal/workspace/github/ministryofjustice/cloud-platform-terraform-awsaccounts-baselines"
# 
#   account_name  = var.aws_account_name
#   region        = var.region
#   slack_webhook = var.baselines_alerts_slack_webhook
#   slack_channel = var.baselines_alerts_slack_channel
# }

#######
# IAM #
#######

module "iam" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-awsaccounts-iam?ref=0.0.1"

  aws_account_name = var.aws_account_name
}

##############
# kOps State #
##############

module "kops_state_backend" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-kops-state-backend?ref=0.0.1"

  bucket_name = "${var.aws_account_name}-kops-state"
}

#######
# DNS #
#######

# New parent DNS zone for clusters
resource "aws_route53_zone" "aws_account_hostzone_id" {
  name = "et.cloud-platform.service.justice.gov.uk."
}

