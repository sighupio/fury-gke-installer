<!-- BEGIN_TF_DOCS -->

# Fury GKE Installer - vpc-and-vpn module

<!-- <KFD-DOCS> -->

## Requirements

| Name | Version |
|------|---------|
| terraform | `>=1.3.0` |

## Providers

| Name | Version |
|------|---------|
| external | `~>2.1.1` |
| google | `~>3.63.0` |
| local | `~>2.1.0` |
| null | `~>3.1.1` |
| random | `~>3.1.3` |

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| cluster\_control\_plane\_cidr\_block | Private subnet CIDR hosting the GKE control plane | `"10.0.0.0/28"` | no |
| cluster\_pod\_subnetwork\_cidr | Private subnet CIDR | n/a | yes |
| cluster\_service\_subnetwork\_cidr | Private subnet CIDR | n/a | yes |
| cluster\_subnetwork\_cidr | Private subnet CIDR | n/a | yes |
| name | Name of the resources. Used as cluster name | n/a | yes |
| private\_subnetwork\_cidrs | Private subnet CIDRs | n/a | yes |
| public\_subnetwork\_cidrs | Public subnet CIDRs | n/a | yes |
| tags | A map of tags to add to all resources | `{}` | no |
| vpn\_dhparams\_bits | Diffie-Hellman (D-H) key size in bytes | `2048` | no |
| vpn\_instance\_disk\_size | VPN main disk size | `50` | no |
| vpn\_instance\_type | GCP instance type | `"n1-standard-1"` | no |
| vpn\_instances | VPN Servers | `1` | no |
| vpn\_operator\_cidrs | VPN Operator cidrs. Used to log into the instance via SSH | ```[ "0.0.0.0/0" ]``` | no |
| vpn\_operator\_name | VPN operator name. Used to log into the instance via SSH | `"sighup"` | no |
| vpn\_port | VPN Server Port | `1194` | no |
| vpn\_ssh\_users | GitHub users id to sync public rsa keys. Example angelbarrera92 | n/a | yes |
| vpn\_subnetwork\_cidr | VPN Subnet CIDR, should be different from the network\_cidr | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| additional\_cluster\_subnet | List of cidr\_blocks of private subnets |
| cluster\_subnet | Names of the cluster subnet |
| cluster\_subnet\_cidr\_blocks | List of cidr\_blocks of private subnets |
| furyagent | furyagent.yml used by the vpn instance and ready to use to create a vpn profile |
| network\_name | The name of the network |
| private\_subnets | List of names of private subnets |
| private\_subnets\_cidr\_blocks | List of cidr\_blocks of private subnets |
| public\_subnets | List of names of public subnets |
| public\_subnets\_cidr\_blocks | List of cidr\_blocks of public subnets |
| vpn\_ip | VPN instance IP |

## Usage

```hcl
module "vpc-and-vpn" {
  source = "../../modules/vpc-and-vpn"

  name = "fury"

  network_cidr             = "10.0.0.0/16"
  public_subnetwork_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnetwork_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  cluster_pod_subnetwork_cidr     = "10.2.0.0/16"
  cluster_service_subnetwork_cidr = "10.3.0.0/16"
  cluster_subnetwork_cidr         = "10.1.0.0/16"

  vpn_subnetwork_cidr = "192.168.200.0/24"
  vpn_ssh_users       = ["github-user"]
}
```

<!-- </KFD-DOCS> -->
<!-- END_TF_DOCS -->