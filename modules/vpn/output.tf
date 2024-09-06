output "furyagent" {
  description = "furyagent.yml used by the vpn instance and ready to use to create a vpn profile"
  sensitive   = true
  value       = local.furyagent_client
}

output "vpn_ip" {
  description = "VPN instance IP"
  value       = google_compute_address.vpn.*.address
}
