

output "route53_root_domain_dns" {
    value = aws_route53_zone.root_aws_account_cloudplatform_justice_gov_uk.name_servers
}