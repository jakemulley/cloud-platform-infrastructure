
variable "baselines_alerts_slack_webhook" {
  description = "Webhook to send alerts to slack when security baselines are not met"
  type        = string
}

variable "baselines_alerts_slack_channel" {
  description = "Webhook to send alerts to slack when security baselines are not met"
  type        = string
}

variable "aws_account_name" {
  description = "The AWS Account name, it is used for naming in multiple resources"
  type        = string
  default     = "cloud-platform-ephemeral-test"
}

variable "aws_region" {
  description = "The AWS Account region name"
  type        = string
  default     = "eu-west-2"
}
