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
  preemptible       = coalesce(node_pool.spot_instance, "false")
  node_pools_taints = zipmap(local.node_names, local.temp_node_pools_taints)

  parsed_master_authorized_networks = [for cidr in local.parsed_dmz_cidr_range : { cidr_block = cidr, display_name = "DMZ CIDR Range" }]
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "14.3.0"

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
  disable_default_snat          = var.gke_disable_default_snat
  add_cluster_firewall_rules    = var.gke_add_cluster_firewall_rules
  master_ipv4_cidr_block        = var.gke_master_ipv4_cidr_block
  deploy_using_private_endpoint = true
  enable_private_endpoint       = true
  enable_private_nodes          = true
  preemptible                   = local.preemptible
  remove_default_node_pool      = true
  monitoring_service            = "none"
  logging_service               = "none"
  http_load_balancing           = false
  network_policy                = true

  master_authorized_networks = local.parsed_master_authorized_networks

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
      image_type           = worker.os != null ? worker.os : "COS"
      node_locations       = worker.subnetworks != null && length(worker.subnetworks) > 0 ? worker.subnetworks[0] : ""
      auto_upgrade         = false
      version              = worker.version != null ? worker.version : var.cluster_version
      max_pods_per_node    = worker.max_pods
    }
  ]
}

resource "google_compute_firewall" "ssh_to_nodes" {
  count         = var.gke_add_additional_firewall_rules ? 1 : 0
  name          = "ssh-access-to-${var.cluster_name}-gke-cluster-nodes"
  network       = var.network
  source_ranges = local.parsed_dmz_cidr_range

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["sighup-io-gke-cluster-${var.cluster_name}"]
}

locals {
  ingress_fw_rules = flatten([
    [for nodePool in var.node_pools : [
      [for rule in nodePool.additional_firewall_rules : {
        name          = rule.name
        description   = "Additional Firewall ${rule.direction} rule for the node pool ${nodePool.name} in the ${var.cluster_name} GKE cluster"
        direction     = upper(rule.direction)
        protocol      = rule.protocol
        ports         = [rule.ports]
        source_ranges = [rule.cidr_block]
        target_tags   = ["gke-${var.cluster_name}-${nodePool.name}"]
      } if upper(rule.direction) == "INGRESS"]
      ]
    ]
  ])
  egress_fw_rules = flatten([
    [for nodePool in var.node_pools : [
      [for rule in nodePool.additional_firewall_rules : {
        name               = rule.name
        description        = "Additional Firewall ${rule.direction} rule for the node pool ${nodePool.name} in the ${var.cluster_name} GKE cluster"
        direction          = upper(rule.direction)
        protocol           = rule.protocol
        ports              = [rule.ports]
        destination_ranges = [rule.cidr_block]
        target_tags        = ["gke-${var.cluster_name}-${nodePool.name}"]
      } if upper(rule.direction) == "EGRESS"]
      ]
    ]
  ])
}

resource "google_compute_firewall" "node_pools_egress" {
  count = length(local.egress_fw_rules)

  name        = local.egress_fw_rules[count.index]["name"]
  description = local.egress_fw_rules[count.index]["description"]
  direction   = local.egress_fw_rules[count.index]["direction"]

  network = var.network

  allow {
    protocol = local.egress_fw_rules[count.index]["protocol"]
    ports    = local.egress_fw_rules[count.index]["ports"]
  }

  destination_ranges = local.egress_fw_rules[count.index]["destination_ranges"]
  target_tags        = local.egress_fw_rules[count.index]["target_tags"]
}

resource "google_compute_firewall" "node_pools_ingress" {
  count = length(local.ingress_fw_rules)

  name        = local.ingress_fw_rules[count.index]["name"]
  description = local.ingress_fw_rules[count.index]["description"]
  direction   = local.ingress_fw_rules[count.index]["direction"]

  network = var.network

  allow {
    protocol = local.ingress_fw_rules[count.index]["protocol"]
    ports    = local.ingress_fw_rules[count.index]["ports"]
  }

  source_ranges = local.ingress_fw_rules[count.index]["source_ranges"]
  target_tags   = local.ingress_fw_rules[count.index]["target_tags"]
}

resource "google_compute_firewall" "gke_webhook" {
  count         = var.gke_add_additional_firewall_rules ? 1 : 0
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

resource "google_compute_firewall" "gatekeeper_webhook" {
  count         = var.gke_add_additional_firewall_rules ? 1 : 0
  name          = "gatekeeper-webhook-access-to-${var.cluster_name}-worker-nodes"
  description   = "Allow access from GKE masters to worker nodes to allow Gatekeeper WebHook"
  network       = var.network
  source_ranges = [module.gke.master_ipv4_cidr_block]

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags = ["sighup-io-gke-cluster-${var.cluster_name}"]
}

resource "google_compute_firewall" "certmanager_webhook" {
  count         = var.gke_add_additional_firewall_rules ? 1 : 0
  name          = "certmanager-webhook-access-to-${var.cluster_name}-worker-nodes"
  description   = "Allow access from GKE masters to worker nodes to allow Certmanager WebHook"
  network       = var.network
  source_ranges = [module.gke.master_ipv4_cidr_block]

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  target_tags = ["sighup-io-gke-cluster-${var.cluster_name}"]
}
