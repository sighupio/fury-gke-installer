<!-- BEGIN_TF_DOCS -->

# Fury GKE Installer - GKE module

<!-- <KFD-DOCS> -->

## Requirements

| Name | Version |
|------|---------|
| terraform | 0.15.4 |
| external | 2.0.0 |
| google | 3.55.0 |
| google-beta | 3.55.0 |
| kubernetes | 1.13.3 |
| null | 3.0.0 |
| random | 3.0.1 |

## Providers

| Name | Version |
|------|---------|
| google | 3.55.0 |

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| cluster\_name | Unique cluster name. Used in multiple resources to identify your cluster resources | n/a | yes |
| cluster\_version | Kubernetes Cluster Version. Look at the cloud provider documentation to discover available versions. Example 1.16.8-gke.9 | n/a | yes |
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
module "my-cluster" {
  source = "../modules/gke"

  cluster_name    = "furyctl"
  cluster_version = "1.20.9-gke.700"
  
  network         = "furyctl"
  subnetworks     = ["furyctl-cluster-subnet", "furyctl-cluster-pod-subnet", "furyctl-cluster-service-subnet"]
  dmz_cidr_range  = "10.0.0.0/8"
  
  ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCefFo9ASM8grncpLpJr+DAeGzTtoIaxnqSqrPeSWlCyManFz5M/DDkbnql8PdrENFU28blZyIxu93d5U0RhXZumXk1utpe0L/9UtImnOGG6/dKv9fV9vcJH45XdD3rCV21ZMG1nuhxlN0DftcuUubt/VcHXflBGaLrs18DrMuHVIbyb5WO4wQ9Od/SoJZyR6CZmIEqag6ADx4aFcdsUwK1Cpc51LhPbkdXGGjipiwP45q0I6/Brjxv/Kia1e+RmIRHiltsVBdKKTL9hqu9esbAod9I5BkBtbB5bmhQUVFZehi+d/opPvsIszE/coW5r/g/EVf9zZswebFPcsNr85+x"
  tags            = {}

  node_pools = [
  {
    name : "node-pool-1"
    version : null # To use the cluster_version
    min_size : 1
    max_size : 1
    instance_type : "n1-standard-1"
    volume_size : 100
    subnetworks : ["europe-west1-b"]
    labels : {
      "sighup.io/role" : "app"
      "sighup.io/fury-release" : "v1.3.0"
    }
    additional_firewall_rules: [{
        name : "debug-1"
        direction : "ingress"
        cidr_block : "10.0.0.0/8"
        protocol : "TCP"
        ports : "80-80"
        tags : {}
      }]
    taints : []
    tags : {}
    # max_pods : null # Default
  },
  {
    name : "node-pool-2"
    version : "1.20.9-gke.700"
    min_size : 1
    max_size : 1
    instance_type : "n1-standard-2"
    volume_size : 50
    subnetworks : ["europe-west1-b"]
    labels : {}
    additional_firewall_rules: [
      {
        name : "debug-2"
        direction : "egress"
        cidr_block : "0.0.0.0/0"
        protocol : "UDP"
        ports : "53-53"
        tags : {"dns" : "true"}
      }]
    taints : [
      "sighup.io/role=app:NoSchedule"
    ]
    tags : {}
    max_pods : 50 # Specific
  }
  ]

}

data "google_client_config" "current" {}
```

<!-- </KFD-DOCS> -->
<!-- END_TF_DOCS -->