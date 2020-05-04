# Create new Route53 zone
# Expect a domain name in input
# Return route53 zone object https://docs.aws.amazon.com/sdkforruby/api/Aws/Route53/Types/CreateHostedZoneResponse.html
def create_zone(domain)
  sleep 1
  client = Aws::Route53::Client.new
  client.create_hosted_zone(
    name: domain,
    caller_reference: readable_timestamp, # required, different each time
    hosted_zone_config: {
      comment: "integrationtest",
      private_zone: false
    }
  )
end

# Retrieves a list of records from an existing Route53 zones
# Expect a zone_id in input
# Returns an array of hashes {type, name, value} of records.
# example:
# [
#   {:type=>"NS", :name=>"test.service.justice.gov.uk.", :value=>["ns-000.awsdns-00.net.", "ns-000.awsdns-00.net.", "ns-000.awsdns-00.net.", "ns-000.awsdns-00.net."]},
#   {:type=>"SOA", :name=>"mourad2.service.justice.gov.uk.", :value=>["ns-000.awsdns-00.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]}
# ]
def get_zone_records(zone_id)
  sleep 1
  client = Aws::Route53::Client.new
  records = client.list_resource_record_sets(
    hosted_zone_id: zone_id # required
  )

  records.resource_record_sets
end

# Deletes a hosted zone.
# Expects a zone_id in input
# Be careful
def delete_zone(zone_id)
  sleep 1
  client = Aws::Route53::Client.new
  client.delete_hosted_zone(
    id: zone_id
  )
end
