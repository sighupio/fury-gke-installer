terraform {
  required_version = "~> 1.4"
  required_providers {
    external   = "~> 2.3.1"
    google     = "~> 3.90.1"
    kubernetes = "~> 1.13.4"
    local      = "~> 2.4.0"
    null       = "~> 3.2.1"
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = "europe-west1"
  zone        = "europe-west1-b"
}

module "vpc-and-vpn" {
  source = "../../modules/vpc-and-vpn"

  name = "fury"

  public_subnetwork_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnetwork_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  cluster_pod_subnetwork_cidr     = "10.2.0.0/16"
  cluster_service_subnetwork_cidr = "10.3.0.0/16"
  cluster_subnetwork_cidr         = "10.1.0.0/16"

  vpn_subnetwork_cidr = "192.168.200.0/24"
  vpn_ssh_users       = var.vpn_ssh_users
}
