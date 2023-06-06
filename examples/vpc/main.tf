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

module "vpc" {
  source = "../../modules/vpc"

  name = var.name

  public_subnetwork_cidrs  = var.public_subnetwork_cidrs
  private_subnetwork_cidrs = var.private_subnetwork_cidrs

  cluster_pod_subnetwork_cidr     = var.cluster_pod_subnetwork_cidr
  cluster_service_subnetwork_cidr = var.cluster_service_subnetwork_cidr
  cluster_subnetwork_cidr         = var.cluster_subnetwork_cidr

}
