variable "vpn_ssh_users" {
  type        = list(string)
  description = "List of ssh users to be added to the VPN instance"
}

variable "gcp_project_id" {
  type        = string
  description = "Id of the GCP project where to deploy the resources"
}
