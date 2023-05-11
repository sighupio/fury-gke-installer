<!-- BEGIN_TF_DOCS -->

# Fury GKE Installer - GKE module

<!-- <KFD-DOCS> -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| external | ~> 2.3 |
| google | ~> 3.90 |
| kubernetes | ~> 1.13 |
| null | ~> 3.2 |
| random | ~> 3.5 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.90 |

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| cluster\_name | Unique cluster name. Used in multiple resources to identify your cluster resources | n/a | yes |
| cluster\_version | Kubernetes Cluster Version. Look at the cloud provider documentation to discover available versions. eg: 1.26.2-gke.1000 | n/a | yes |
| dmz\_cidr\_range | Network CIDR range from where cluster control plane will be accessible | n/a | yes |
| gke\_add\_additional\_firewall\_rules | [GKE] Create additional firewall rules | `true` | no |
| gke\_add\_cluster\_firewall\_rules | [GKE] Create additional firewall rules (Upstream GKE module) | `false` | no |
| gke\_disable\_default\_snat | [GKE] Whether to disable the default SNAT to support the private use of public IP addresses | `false` | no |
| gke\_master\_ipv4\_cidr\_block | [GKE] The IP range in CIDR notation to use for the hosted master network | `"10.0.0.0/28"` | no |
| gke\_network\_project\_id | [GKE] The project ID of the shared VPC's host (for shared vpc support) | `""` | no |
| network | Network name where the Kubernetes cluster will be hosted | n/a | yes |
| node\_pools | An object list defining node pools configurations | `[]` | no |
| resource\_group\_name | [Azure] Resource group name where every resource will be placed | `""` | no |
| ssh\_public\_key | Cluster administrator public SSH key. Used to access cluster nodes with the operator\_ssh\_user | n/a | yes |
| subnetworks | List of subnets where the cluster will be hosted | n/a | yes |
| tags | Tags to apply to all resources | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_certificate\_authority | The base64 encoded certificate data required to communicate with your cluster. Add this to the certificate-authority-data section of the kubeconfig file for your cluster |
| cluster\_endpoint | The endpoint for your Kubernetes API server |
| operator\_ssh\_user | SSH user to access cluster nodes with ssh\_public\_key |

## Usage

```hcl
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
```

<!-- </KFD-DOCS> -->
<!-- END_TF_DOCS -->