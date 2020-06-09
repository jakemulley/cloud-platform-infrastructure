
terraform {
  backend "s3" {
    bucket         = "cloud-platform-ephemeral-test-tfstate"
    region         = "eu-west-2"
    key            = "global-resources/iam/terraform.tfstate"
    dynamodb_table = "cloud-platform-ephemeral-test-tfstate"
    encrypt        = true
  }
}
