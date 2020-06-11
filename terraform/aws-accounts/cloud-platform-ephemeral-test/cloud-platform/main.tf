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

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.vpc]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    SubnetType = "Utility"
  }
}

# Unfortunately data.template_file.kops resource only receives individual subnets with the 
# AZs already mapped. Since terraform 0.12 there is a better way to do it using templatefile 
# ( https://www.terraform.io/docs/configuration/functions/templatefile.html ) and passing 
# the whole array of subnets with AZ included, it will involve using a something like 
# %{ for subnets in subnets_all ~} # inside the templates/kops.yaml.tpl. For this PR the 
# idea is to change the least possible, following PRs will be coming to make it better.

data "aws_subnet" "private_a" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-2a"

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "private_b" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-2b"

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "private_c" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-2c"

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "public_a" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-2a"

  tags = {
    SubnetType = "Utility"
  }
}

data "aws_subnet" "public_b" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-2b"

  tags = {
    SubnetType = "Utility"
  }
}

data "aws_subnet" "public_c" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-2c"

  tags = {
    SubnetType = "Utility"
  }
}


# Modules
module "cluster_dns" {
  source                   = "../modules/cluster_dns"
  cluster_base_domain_name = local.cluster_base_domain_name
  parent_zone_id           = data.terraform_remote_state.global.outputs.cp_zone_id
}

module "cluster_ssl" {
  source                   = "../modules/cluster_ssl"
  cluster_base_domain_name = local.cluster_base_domain_name
  dns_zone_id              = module.cluster_dns.cluster_dns_zone_id
}

resource "tls_private_key" "cluster" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "cluster" {
  key_name   = local.cluster_base_domain_name
  public_key = tls_private_key.cluster.public_key_openssh
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
