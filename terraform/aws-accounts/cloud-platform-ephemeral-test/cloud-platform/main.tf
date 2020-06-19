
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket               = "cloud-platform-ephemeral-test-tfstate"
    region               = "eu-west-2"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "cloud-platform"
    dynamodb_table       = "cloud-platform-ephemeral-test-tfstate"
    encrypt              = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Check module source: https://github.com/ministryofjustice/cloud-platform-terraform-auth0
provider "auth0" {
  version = ">= 0.2.1"
  domain  = var.auth0_tenant_domain
}

data "terraform_remote_state" "global" {
  backend = "s3"

  config = {
    bucket = "cloud-platform-ephemeral-test-tfstate"
    region = "eu-west-2"
    key    = "global-resources/terraform.tfstate"
  }
}

###########################
# Locals & Data Resources #
###########################

locals {
  account_root_hostzone_name = data.terraform_remote_state.global.outputs.aws_account_hostzone_name
  cluster_name               = terraform.workspace
  cluster_base_domain_name   = "${local.cluster_name}.${local.account_root_hostzone_name}"
  vpc_name                   = var.vpc_name != "" ? var.vpc_name : terraform.workspace
}

########
# KOPS #
########

module "kops" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-kops?ref=main"

  vpc_name                = local.vpc_name
  cluster_domain_name     = trimsuffix(local.cluster_base_domain_name, ".")
  kops_state_store        = data.terraform_remote_state.global.outputs.kops_state_s3_bucket_name[0]
  auth0_client_id         = module.auth0.oidc_kubernetes_client_id
  authorized_keys_manager = module.bastion.authorized_keys_manager

  cluster_node_count       = lookup(var.cluster_node_count, terraform.workspace, var.cluster_node_count["default"])
  master_node_machine_type = lookup(var.master_node_machine_type, terraform.workspace, var.master_node_machine_type["default"])
  worker_node_machine_type = lookup(var.worker_node_machine_type, terraform.workspace, var.worker_node_machine_type["default"])
  enable_large_nodesgroup  = lookup(var.enable_large_nodesgroup, terraform.workspace, var.enable_large_nodesgroup["default"])

  template_path   = "../../../../kops"
  oidc_issuer_url = "https://${var.auth0_tenant_domain}/"
}

#########
# Auth0 #
#########

module "auth0" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-auth0?ref=0.0.2"

  cluster_name         = local.cluster_name
  services_base_domain = local.cluster_base_domain_name
}

###########
# BASTION #
###########

module "bastion" {
  #source = "github.com/ministryofjustice/cloud-platform-terraform-bastion?ref=1.1.0"
  source = "/Users/mogaal/workspace/github/ministryofjustice/cloud-platform-terraform-bastion"

  vpc_name            = local.vpc_name
  route53_zone        = aws_route53_zone.cluster.name
  cluster_domain_name = local.cluster_base_domain_name
}

################
# DNS Hostzone #
################

resource "aws_route53_zone" "cluster" {
  name          = local.cluster_base_domain_name
  force_destroy = true
}

resource "aws_route53_record" "parent_zone_cluster_ns" {
  zone_id = data.terraform_remote_state.global.outputs.aws_account_hostzone_id
  name    = aws_route53_zone.cluster.name
  type    = "NS"
  ttl     = "30"

  records = [
    aws_route53_zone.cluster.name_servers.0,
    aws_route53_zone.cluster.name_servers.1,
    aws_route53_zone.cluster.name_servers.2,
    aws_route53_zone.cluster.name_servers.3,
  ]
}
