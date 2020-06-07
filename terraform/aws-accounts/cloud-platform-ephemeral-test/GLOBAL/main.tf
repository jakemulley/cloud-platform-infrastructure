
terraform {
  backend "s3" {
    bucket         = "ale-mogaal-test"
    region         = "eu-west-2"
    key            = "global-resources/iam/terraform.tfstate"
    dynamodb_table = "ale-mogaal-test"
    encrypt        = true
  }
}
