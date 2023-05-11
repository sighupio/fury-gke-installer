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

provider "kubernetes" {
  load_config_file       = false
  host                   = module.my_cluster.cluster_endpoint
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(module.my_cluster.cluster_certificate_authority)
}

data "google_client_config" "current" {}

module "my_cluster" {
  source = "../../modules/gke"

  cluster_name    = "fury"
  cluster_version = "1.25.7-gke.1000"

  network         = "fury"
  subnetworks     = ["fury-cluster-subnet", "fury-cluster-pod-subnet", "fury-cluster-service-subnet"]
  dmz_cidr_range  = "10.0.0.0/8"

  ssh_public_key  = var.ssh_public_key
  tags            = {}

  node_pools = [
    {
      name: "node-pool-1"
      version: null # To use the cluster_version
      min_size: 1
      max_size: 1
      instance_type: "n1-standard-1"
      volume_size: 100
      subnetworks: ["europe-west1-b"]
      labels: {
        "sighup.io/role": "app"
        "sighup.io/fury-release": "v1.25.0"
      }
      additional_firewall_rules: [{
          name: "debug-1"
          direction: "ingress"
          cidr_block: "10.0.0.0/8"
          protocol: "TCP"
          ports: "80-80"
          tags: {}
        }
      ]
      taints: []
      tags: {}
      # max_pods: null # Default
    },
    {
      name: "node-pool-2"
      version: "1.25.7-gke.1000"
      min_size: 1
      max_size: 1
      instance_type: "n1-standard-2"
      os: "COS_CONTAINERD" # to select a particular OS image, optional. Default: COS: Container-Optimized OS, using containerd
      volume_size: 50
      subnetworks: ["europe-west1-b"]
      labels: {}
      additional_firewall_rules: [
        {
          name: "debug-2"
          direction: "egress"
          cidr_block: "0.0.0.0/0"
          protocol: "UDP"
          ports: "53-53"
          tags: {"dns": "true"}
        }
      ]
      taints: [
        "sighup.io/role=app:NoSchedule"
      ]
      tags: {}
      max_pods: 50 # Specific
      spot_instance: true # create preemptible instances instead of the standard ones, optional
    }
  ]
}
