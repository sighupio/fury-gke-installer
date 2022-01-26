<h1>
    <img src="./docs/assets/fury_installer.png?raw=true" align="left" width="105" style="margin-right: 15px"/>
    Fury GKE Installer
</h1>

![Release](https://img.shields.io/github/v/release/sighupio/fury-gke-installer?label=Latest%20Release)
![License](https://img.shields.io/github/license/sighupio/fury-gke-installer?label=License)
[![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)](https://kubernetes.slack.com/archives/C0154HYTAQH)

<!-- <KFD-DOCS> -->

**Fury GKE Installer** deploys a production-grade Kubernetes Fury cluster based on Google Kubernetes Engine (GKE).

If you are new to Kubernetes Fury please refer to the [official documentation][kfd-docs] on how to get started.

## Modules

The installer is composed of two different terraform modules:

|            Module             |                  Description                   |
| ----------------------------- | ---------------------------------------------- |
| [VPC and VPN][vpc-vpn-module] | Deploy the necessary networking infrastructure |
| [GKE][gke-module]             | Deploy the GKE cluster                         |

Click on each module to see its full documentation.

## Architecture

The GKE installers deploys and configures a production-ready GKE cluster without having to learn all internals of the service.

<img src="./docs/assets/fury_installer_architecture.jpg?raw=true" width="800" style="margin: 0 auto"/>

The [GKE module][gke-module] deploys a **private control plane** cluster, where the control plane endpoint is not publicly accessible.

The [VPC and VPN module][vpc-vpn-module] setups all the necessary networking infrastructure and a bastion host.

The bastion host includes a OpenVPN instance easily manageable by using [furyagent][furyagent] to provide access to the cluster.

> 🕵🏻‍♂️ [Furyagent][furyagent] is a tool developed by SIGHUP to manage OpenVPN and SSH user access to the bastion host.

## Usage

### Requirements

- **GCP Access Credentials** of a GCP Account with `Project Owner` role with the following APIs enabled:
  - *Identity and Access Management (IAM) API*
  - *Compute Engine API*
  - *Cloud Resource Manager API*
  - *Kubernetes Engine API*
- **terraform** `0.15.4`
- `ssh` or **OpenVPN Client** - [Tunnelblick][tunnelblick] (on macOS) or [OpenVPN Connect][openvpn-connect] (for other OS) are recommended.

### Create GKE Cluster

To create the cluster via the installers:

1. Use the [VPC and VPN module][vpc-vpn-module] to deploy the networking infrastructure

2. Configure access to the OpenVPN instance of the bastion host via [furyagent][furyagent]

3. Connect to the OpenVPN instance

4. Use the [GKE module][gke-module] to deploy the GKE cluster

Please refer to each module documentation and the [example](example/) folder for more details.

> You can follow the [Fury on GKE quick start guide][fury-gke-quickstart] for a more detailed walkthrough

<!-- Links -->

[vpc-vpn-module]: ./modules/vpc-and-vpn
[gke-module]: ./modules/eks
[kfd-docs]: https://docs.kubernetesfury.com/docs/distribution/

[furyagent]: https://github.com/sighupio/furyagent
[tunnelblick]: https://tunnelblick.net/downloads.html
[openvpn-connect]: https://openvpn.net/vpn-client/
[fury-gke-quickstart]: https://docs.kubernetesfury.com/docs/fury-on-gke

<!-- </KFD-DOCS> -->
<!-- <FOOTER> -->

## Contributing

Before contributing, please read first the [Contributing Guidelines](docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/fury-kubernetes-networking/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)

<!-- </FOOTER> -->
