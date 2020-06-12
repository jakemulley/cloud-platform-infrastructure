# Setup
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket               = "cloud-platform-terraform-state"
    region               = "eu-west-1"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "cloud-platform"
    profile              = "moj-cp"
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "moj-cp"
}

# Please check module source:
# https://github.com/ministryofjustice/cloud-platform-terraform-auth0/blob/master/main.tf
provider "auth0" {
  version = ">= 0.2.1"
  domain  = var.auth0_tenant_domain
}

data "terraform_remote_state" "global" {
  backend = "s3"

  config = {
    bucket  = "cloud-platform-terraform-state"
    region  = "eu-west-1"
    key     = "global-resources/terraform.tfstate"
    profile = "moj-cp"
  }
}

###########################
# Locals & Data Resources #
###########################

locals {
  cluster_name             = terraform.workspace
  cluster_base_domain_name = "${local.cluster_name}.cloud-platform.service.justice.gov.uk"
  vpc                      = var.vpc_name == "" ? terraform.workspace : var.vpc_name
}

########
# KOPS #
########

module "kops" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-auth0?ref=0.0.2"

  cluster_base_domain_name = vpc_name
  parent_zone_id           = data.terraform_remote_state.global.outputs.cp_zone_id
}

#########
# Auth0 #
#########

module "auth0" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-auth0?ref=0.0.2"

  cluster_name         = local.cluster_name
  services_base_domain = local.services_base_domain
}

###########
# BASTION #
###########

module "bastion" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-bastion?ref=1.0.0"

  vpc_id         = data.aws_vpc.selected.id
  public_subnets = tolist(data.aws_subnet_ids.public.ids)
  key_name       = aws_key_pair.cluster.key_name
  route53_zone   = module.cluster_dns.cluster_dns_zone_name
}
