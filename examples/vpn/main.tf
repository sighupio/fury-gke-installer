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

module "vpn" {
  source = "../../modules/vpn"

  name = "fury"

  network = var.network
  public_subnetworks = var.public_subnetworks
  public_subnetwork_cidrs = var.public_subnetwork_cidrs

  vpn_subnetwork_cidr = "192.168.200.0/24"
  vpn_ssh_users       = var.vpn_ssh_users
}
