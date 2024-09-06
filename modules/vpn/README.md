<!-- BEGIN_TF_DOCS -->

# Fury GKE Installer - vpn module

<!-- <KFD-DOCS> -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| external | ~> 2.3 |
| google | ~> 3.90 |
| local | ~> 2.4 |
| null | ~> 3.2 |
| random | ~> 3.5 |

## Providers

| Name | Version |
|------|---------|
| external | ~> 2.3 |
| google | ~> 3.90 |
| local | ~> 2.4 |
| null | ~> 3.2 |
| random | ~> 3.5 |

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| cluster\_control\_plane\_cidr\_block | Private subnet CIDR hosting the GKE control plane | `"10.0.0.0/28"` | no |
| name | Name of the resources. Used as cluster name | n/a | yes |
| public\_subnetworks | Public subnet names | n/a | yes |
| public\_subnetwork\_cidrs | Public subnet CIDRs | n/a | yes |
| tags | A map of tags to add to all resources | `{}` | no |
| vpn\_dhparams\_bits | Diffie-Hellman (D-H) key size in bytes | `2048` | no |
| vpn\_instance\_disk\_size | VPN main disk size | `50` | no |
| vpn\_instance\_type | GCP instance type | `"n1-standard-1"` | no |
| vpn\_instances | VPN Servers | `1` | no |
| vpn\_operator\_cidrs | VPN Operator cidrs. Used to log into the instance via SSH | ```[ "0.0.0.0/0" ]``` | no |
| vpn\_operator\_name | VPN operator name. Used to log into the instance via SSH | `"sighup"` | no |
| vpn\_port | VPN Server Port | `1194` | no |
| vpn\_ssh\_users | GitHub users id to sync public rsa keys. eg: jnardiello | n/a | yes |
| vpn\_subnetwork\_cidr | VPN Subnet CIDR, should be different from the network\_cidr | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| furyagent | furyagent.yml used by the vpn instance and ready to use to create a vpn profile |
| vpn\_ip | VPN instance IP |

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

module "vpn" {
  source = "../../modules/vpn"

  name = "fury"

  public_subnetwork_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnetwork_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  vpn_subnetwork_cidr = "192.168.200.0/24"
  vpn_ssh_users       = var.vpn_ssh_users
}
```

<!-- </KFD-DOCS> -->
<!-- END_TF_DOCS -->