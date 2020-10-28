cluster_name    = "my-cluster"
cluster_version = "1.15.12-gke.6"
network         = "gke-vpc"
subnetworks     = ["gke-subnet", "gke-subnet-pod", "gke-subnet-svc"]
ssh_public_key  = "ssh-rsa example"
dmz_cidr_range  = "10.10.0.0/16"
tags            = {}
node_pools = [
  {
    name : "node-pool-1"
    version : null # To use the cluster_version
    min_size : 1
    max_size : 1
    instance_type : "n1-standard-1"
    volume_size : 100
    labels : {
      "sighup.io/role" : "app"
      "sighup.io/fury-release" : "v1.3.0"
    }
    taints : []
    tags : {}
    max_pods : null # Default
  },
  {
    name : "node-pool-2"
    version : "1.15.12-gke.6"
    min_size : 1
    max_size : 1
    instance_type : "n1-standard-2"
    volume_size : 50
    labels : {}
    taints : [
      "sighup.io/role=app:NoSchedule"
    ]
    tags : {}
    max_pods : 100 # Default
  }
]
