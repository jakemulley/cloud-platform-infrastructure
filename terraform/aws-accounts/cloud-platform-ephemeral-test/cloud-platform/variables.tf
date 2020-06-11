variable "vpc_name" {
  description = "The VPC name where the cluster(s) are going to be provisioned. VPCs are created in cloud-platform-network"
  default     = ""
}

variable "auth0_tenant_domain" {
  description = "This is the auth0 tenant domain"
  value = "justice-cloud-platform.eu.auth0.com"
}

variable "cluster_node_count" {
  description = "The number of worker node in the cluster"
  default     = "21"
}

variable "master_node_machine_type" {
  description = "The AWS EC2 instance types to use for master nodes"
  default     = "c4.4xlarge"
}

variable "worker_node_machine_type" {
  description = "The AWS EC2 instance types to use for worker nodes"
  default     = "r5.xlarge"
}

variable "enable_large_nodesgroup" {
  description = "Due to Prometheus resource consumption we added a larger node groups (r5.2xlarge), this variable you enable the creation of it"
  type        = bool
  default     = true
}
