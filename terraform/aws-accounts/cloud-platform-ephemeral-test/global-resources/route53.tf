
# new parent DNS zone for clusters
resource "aws_route53_zone" "root_aws_account_cloudplatform_justice_gov_uk" {
  name     = "ephemeral-test.cloud-platform.service.justice.gov.uk."
}

