# GCP VPC and VPN

## Providers

| Name     | Version |
| -------- | ------- |
| external | 2.0.0   |
| google   | 3.55.0  |
| local    | 2.0.0   |
| null     | 3.0.0   |
| random   | 3.0.1   |

## Inputs

| Name                             | Description                                                     | Type           | Default                                | Required |
| -------------------------------- | --------------------------------------------------------------- | -------------- | -------------------------------------- | :------: |
| cluster_pod_subnetwork_cidr      | Private subnet CIDR                                             | `string`       | n/a                                    |   yes    |
| cluster_service_subnetwork_cidr  | Private subnet CIDR                                             | `string`       | n/a                                    |   yes    |
| cluster_subnetwork_cidr          | Private subnet CIDR                                             | `string`       | n/a                                    |   yes    |
| name                             | Name of the resources. Used as cluster name                     | `string`       | n/a                                    |   yes    |
| private_subnetwork_cidrs         | Private subnet CIDRs                                            | `list(string)` | n/a                                    |   yes    |
| public_subnetwork_cidrs          | Public subnet CIDRs                                             | `list(string)` | n/a                                    |   yes    |
| vpn_ssh_users                    | GitHub users id to sync public rsa keys. Example angelbarrera92 | `list(string)` | n/a                                    |   yes    |
| vpn_subnetwork_cidr              | VPN Subnet CIDR, should be different from the network_cidr      | `string`       | n/a                                    |   yes    |
| cluster_control_plane_cidr_block | Private subnet CIDR hosting the GKE control plane               | `string`       | `"10.0.0.0/28"`                        |    no    |
| tags                             | A map of tags to add to all resources                           | `map(string)`  | `{}`                                   |    no    |
| vpn_dhparams_bits                | Diffie–Hellman (D-H) key size in bytes                          | `number`       | `2048`                                 |    no    |
| vpn_instance_disk_size           | VPN main disk size                                              | `number`       | `50`                                   |    no    |
| vpn_instance_type                | GCP instance type                                               | `string`       | `"n1-standard-1"`                      |    no    |
| vpn_instances                    | VPN Servers                                                     | `number`       | `1`                                    |    no    |
| vpn_operator_cidrs               | VPN Operator cidrs. Used to log into the instance via SSH       | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> |    no    |
| vpn_operator_name                | VPN operator name. Used to log into the instance via SSH        | `string`       | `"sighup"`                             |    no    |
| vpn_port                         | VPN Server Port                                                 | `number`       | `1194`                                 |    no    |

## Outputs

| Name                        | Description                                                                     |
| --------------------------- | ------------------------------------------------------------------------------- |
| cluster_pod_subnet          | List of cidr_blocks of private subnets                                          |
| cluster_subnet              | List of names of private subnets                                                |
| cluster_subnet_cidr_blocks  | List of cidr_blocks of private subnets                                          |
| furyagent                   | furyagent.yml used by the vpn instance and ready to use to create a vpn profile |
| network_name                | The name of the network                                                         |
| private_subnets             | List of names of private subnets                                                |
| private_subnets_cidr_blocks | List of cidr_blocks of private subnets                                          |
| public_subnets              | List of names of public subnets                                                 |
| public_subnets_cidr_blocks  | List of cidr_blocks of public subnets                                           |
| vpn_ip                      | VPN instance IP                                                                 |
