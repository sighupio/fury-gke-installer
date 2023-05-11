variable "gcp_project_id" {
  type        = string
  description = "Id of the GCP project where to deploy the resources"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to use for the cluster nodes"
}
