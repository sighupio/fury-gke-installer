
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
