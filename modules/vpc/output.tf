locals {
  public_subnets = [for subnet in module.vpc.subnets :
    {
      subnet_name   = subnet.name
      subnet_ip     = subnet.ip_cidr_range
      subnet_region = subnet.region
      secondary_ip_range_names = [for secondary_range in subnet.secondary_ip_range : secondary_range.range_name]
    }
    if contains(var.public_subnetwork_cidrs, subnet.ip_cidr_range)
  ]

  private_subnets = [for subnet in module.vpc.subnets :
    {
      subnet_name   = subnet.name
      subnet_ip     = subnet.ip_cidr_range
      subnet_region = subnet.region
    }
    if contains(var.private_subnetwork_cidrs, subnet.ip_cidr_range)
  ]

  cluster_private_subnet = [for subnet in module.vpc.subnets :
    {
      subnet_name   = subnet.name
      subnet_ip     = subnet.ip_cidr_range
      subnet_region = subnet.region
    }
    if contains([var.cluster_subnetwork_cidr], subnet.ip_cidr_range)
  ]
}

output "network_name" {
  description = "The name of the network"
  value       = module.vpc.network_name
}

output "public_subnets" {
  description = "List of names of public subnets"
  value       = local.public_subnets.*.subnet_name
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = local.public_subnets.*.subnet_ip
}

output "private_subnets" {
  description = "List of names of private subnets"
  value       = local.private_subnets.*.subnet_name
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = local.private_subnets.*.subnet_ip
}

output "cluster_subnet" {
  description = "Names of the cluster subnet"
  value       = local.cluster_private_subnet[0].subnet_name
}

output "cluster_subnet_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = local.cluster_private_subnet[0].subnet_ip
}

output "additional_cluster_subnet" {
  description = "List of cidr_blocks of private subnets"
  value       = [for subnet in module.vpc.subnets : [for secondary_range in subnet.secondary_ip_range : { "name" = secondary_range.range_name, "cidr" = secondary_range.ip_cidr_range }] if contains([var.cluster_subnetwork_cidr], subnet.ip_cidr_range)]
}
