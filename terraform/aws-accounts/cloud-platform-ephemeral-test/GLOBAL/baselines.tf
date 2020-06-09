
module "baselines" {
  #source = "github.com/ministryofjustice/cloud-platform-terraform-awsaccounts-iam?ref=0.0.1"
  source = "/Users/mogaal/workspace/github/ministryofjustice/cloud-platform-terraform-awsaccounts-baselines"

  account_name = "cloud-platform-ephemeral-test"
  region           = "eu-west-2"
}
