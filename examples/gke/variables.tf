variable "gcp_project_id" {
  type        = string
  description = "Id of the GCP project where to deploy the resources"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to use for the cluster nodes"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version"
}

variable "network_name" {
  type        = string
  description = "Name of the network where to deploy the cluster"
}

variable "subnetworks_names" {
  type        = list(string)
  description = "Names of the subnetworks where to deploy the cluster"
}
