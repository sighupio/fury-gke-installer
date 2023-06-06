variable "gcp_project_id" {
  type        = string
  description = "Id of the GCP project where to deploy the resources"
}

variable "name" {
  type        = string
  description = "Common name for the project"
}

variable "public_subnetwork_cidrs" {
  type = list(string)
  
}

variable "private_subnetwork_cidrs" {
  type = list(string)
}

variable "cluster_pod_subnetwork_cidr" {
  type = string
}

variable "cluster_service_subnetwork_cidr" {
  type = string
}

variable "cluster_subnetwork_cidr" {
  type = string
}