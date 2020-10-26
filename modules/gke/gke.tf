data "google_client_config" "current" {}

locals {
  node_names = var.node_pools[*].name
  temp_node_pools_labels = [
    for node_pool in var.node_pools :
    merge(
      var.tags,
      node_pool.tags,
      node_pool.labels,
      {
        "sighup.io/cluster"   = var.cluster_name,
        "sighup.io/node_pool" = node_pool.name
      }
    )
  ]
  node_pools_labels = zipmap(local.node_names, local.temp_node_pools_labels)
  node_taint_effect = {
    "NoExecute"        = "NO_EXECUTE",
    "NoSchedule"       = "NO_SCHEDULE"
    "PreferNoSchedule" = "PREFER_NO_SCHEDULE"
  }
  temp_node_pools_taints = [
    for node_pool in var.node_pools : [
      for taint in node_pool.taints :
      {
        "key"    = element(split("=", taint), 0),
        "value"  = element(split(":", element(split("=", taint), 1)), 0),
        "effect" = lookup(local.node_taint_effect, element(split(":", taint), 1)),
      }
    ]
  ]
  node_pools_taints = zipmap(local.node_names, local.temp_node_pools_taints)
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "12.0.0"

  project_id                    = data.google_client_config.current.project
  name                          = var.cluster_name
  cluster_resource_labels       = var.tags
  kubernetes_version            = var.cluster_version
  region                        = data.google_client_config.current.region
  regional                      = true
  network_project_id            = var.gke_network_project_id
  network                       = var.network
  subnetwork                    = var.subnetworks[0]
  ip_range_pods                 = var.subnetworks[1]
  ip_range_services             = var.subnetworks[2]
  master_ipv4_cidr_block        = var.gke_master_ipv4_cidr_block
  deploy_using_private_endpoint = true
  enable_private_endpoint       = true
  enable_private_nodes          = true
  remove_default_node_pool      = true
  monitoring_service            = "none"
  logging_service               = "none"
  http_load_balancing           = false

  master_authorized_networks = [
    {
      cidr_block   = var.dmz_cidr_range
      display_name = "DMZ CIDR Range"
    },
  ]

  master_global_access_enabled = false

  node_pools_tags = {
    all = ["sighup-io-gke-cluster-${var.cluster_name}"]
  }

  node_pools_metadata = {
    all = {
      sshKeys = "ubuntu:${var.ssh_public_key}"
    }
  }

  node_pools_labels = local.node_pools_labels

  node_pools_taints = local.node_pools_taints

  node_metadata = "SECURE"

  node_pools = [
    for worker in var.node_pools :
    {
      name                 = worker.name
      machine_type         = worker.instance_type
      asg_desired_capacity = worker.min_size
      initial_node_count   = worker.min_size
      min_count            = worker.min_size
      max_count            = worker.max_size
      disk_size_gb         = worker.volume_size
      auto_upgrade         = false
      version              = worker.version != null ? worker.version : var.cluster_version
    }
  ]
}

resource "google_compute_firewall" "ssh_to_nodes" {
  name          = "ssh-access-to-${var.cluster_name}-gke-cluster-nodes"
  network       = var.network
  source_ranges = [var.dmz_cidr_range]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["sighup-io-gke-cluster-${var.cluster_name}"]
}

resource "google_compute_firewall" "gke_webhook" {
  name          = "control-plane-access-to-${var.cluster_name}-worker-nodes"
  description   = "Allow access from GKE masters to worker nodes to allow WebHook functionalities"
  network       = var.network
  source_ranges = [module.gke.master_ipv4_cidr_block]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags = ["sighup-io-gke-cluster-${var.cluster_name}"]
}
