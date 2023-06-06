variable "name" {
  description = "Name of the resources. Used as cluster name"
  type        = string
}

variable "public_subnetwork_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)

}

variable "private_subnetwork_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "cluster_subnetwork_cidr" {
  description = "Private subnet CIDR"
  type        = string
}

variable "cluster_pod_subnetwork_cidr" {
  description = "Private subnet CIDR"
  type        = string
}

variable "cluster_service_subnetwork_cidr" {
  description = "Private subnet CIDR"
  type        = string
}
