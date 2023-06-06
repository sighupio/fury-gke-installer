locals {
  vpc_public_subnets = [for public_subnetwork_cidr in var.public_subnetwork_cidrs :
    {
      subnet_name   = "${var.name}-public-subnet-${index(var.public_subnetwork_cidrs, public_subnetwork_cidr) + 1}"
      subnet_ip     = public_subnetwork_cidr
      subnet_region = data.google_client_config.this.region
    }
  ]
  public_subnets = [for subnet in module.vpc.subnets :
    {
      subnet_name   = subnet.name
      subnet_ip     = subnet.ip_cidr_range
      subnet_region = subnet.region
    }
    if contains(var.public_subnetwork_cidrs, subnet.ip_cidr_range)
  ]
  vpc_private_subnets = [for private_subnetwork_cidr in var.private_subnetwork_cidrs :
    {
      subnet_name           = "${var.name}-private-subnet-${index(var.private_subnetwork_cidrs, private_subnetwork_cidr) + 1}"
      subnet_ip             = private_subnetwork_cidr
      subnet_region         = data.google_client_config.this.region
      subnet_private_access = "true"
    }
  ]
  private_subnets = [for subnet in module.vpc.subnets :
    {
      subnet_name   = subnet.name
      subnet_ip     = subnet.ip_cidr_range
      subnet_region = subnet.region
    }
    if contains(var.private_subnetwork_cidrs, subnet.ip_cidr_range)
  ]
  vpc_cluster_private_subnet = [
    {
      subnet_name           = "${var.name}-cluster-subnet"
      subnet_ip             = var.cluster_subnetwork_cidr
      subnet_region         = data.google_client_config.this.region
      subnet_private_access = "true"
    }
  ]
  cluster_private_subnet = [for subnet in module.vpc.subnets :
    {
      subnet_name   = subnet.name
      subnet_ip     = subnet.ip_cidr_range
      subnet_region = subnet.region
    }
    if contains([var.cluster_subnetwork_cidr], subnet.ip_cidr_range)
  ]

  private_nat_subnetworks = [for subnet in module.vpc.subnets :
    {
      name                     = subnet.name
      source_ip_ranges_to_nat  = [subnet.ip_cidr_range]
      secondary_ip_range_names = []
    }
    if contains(var.private_subnetwork_cidrs, subnet.ip_cidr_range)
  ]
  cluster_nat_subnetworks = [for subnet in module.vpc.subnets :
    {
      name                     = subnet.name
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = [for secondary_range in subnet.secondary_ip_range : secondary_range.range_name]
    }
    if contains([var.cluster_subnetwork_cidr], subnet.ip_cidr_range)
  ]
  nat_subnetworks = concat(local.private_nat_subnetworks, local.cluster_nat_subnetworks)
  vpc_subnets     = concat(local.vpc_public_subnets, concat(local.vpc_private_subnets, local.vpc_cluster_private_subnet))
  subnets         = concat(local.public_subnets, concat(local.private_subnets, local.cluster_private_subnet))
}


module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "3.0.1"

  project_id   = data.google_client_config.this.project
  network_name = var.name
  routing_mode = "REGIONAL"

  subnets = local.vpc_subnets

  secondary_ranges = {
    "${var.name}-cluster-subnet" = [
      {
        range_name    = "${var.name}-cluster-pod-subnet"
        ip_cidr_range = var.cluster_pod_subnetwork_cidr
      },
      {
        range_name    = "${var.name}-cluster-service-subnet"
        ip_cidr_range = var.cluster_service_subnetwork_cidr
      }
    ]
  }
}

resource "google_compute_address" "this_nat" {
  name = "${var.name}-nat"
}

module "nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "1.3.0"
  project_id                         = data.google_client_config.this.project
  region                             = data.google_client_config.this.region
  router                             = var.name
  create_router                      = true
  network                            = module.vpc.network_name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ips = [
    google_compute_address.this_nat.self_link,
  ]
  subnetworks = local.nat_subnetworks
}
