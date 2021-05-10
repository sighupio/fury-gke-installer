output "furyagent" {
  description = "furyagent.yml used by the vpn instance and ready to use to create a vpn profile"
  sensitive   = true
  value       = local.furyagent_client
}

output "vpn_ip" {
  description = "VPN instance IP"
  value       = google_compute_address.vpn.*.address
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
