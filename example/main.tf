variable "cluster_name" {}
variable "cluster_version" {}
variable "network" {}
variable "subnetworks" { type = list }
variable "dmz_cidr_range" {}
variable "ssh_public_key" {}
variable "node_pools" { type = list }

module "my-cluster" {
  source = "../modules/gke"

  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  network         = var.network
  subnetworks     = var.subnetworks
  ssh_public_key  = var.ssh_public_key
  dmz_cidr_range  = var.dmz_cidr_range
  node_pools      = var.node_pools
}

data "google_client_config" "current" {}

output "kubeconfig" {
  sensitive = true
  value     = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${module.my-cluster.cluster_certificate_authority}
    server: ${module.my-cluster.cluster_endpoint}
  name: gke
contexts:
- context:
    cluster: gke
    user: gke
  name: gke
current-context: gke
kind: Config
preferences: {}
users:
- name: gke
  user:
    token: ${data.google_client_config.current.access_token}
EOT
}
