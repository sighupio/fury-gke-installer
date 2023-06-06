variable "vpn_ssh_users" {
  type        = list(string)
  description = "List of ssh users to be added to the VPN instance"
}

variable "gcp_project_id" {
  type        = string
  description = "Id of the GCP project where to deploy the resources"
}

variable "network" {
  type        = string
  description = "Network name where the Kubernetes cluster will be hosted"
}

variable "public_subnetwork_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "public_subnetworks" {
  description = "Public subnet names"
  type        = list(string)
}
