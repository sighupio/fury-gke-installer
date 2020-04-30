cluster_name    = "my-cluster"
cluster_version = "1.14.10-gke.34"
network         = "gke-vpc"
subnetworks     = ["gke-subnet", "gke-subnet-pod", "gke-subnet-svc"]
ssh_public_key = "ssh-rsa example
dmz_cidr_range = "10.10.0.0/16"
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
      "sighup.io/fury-release" : "v1.2.0-rc1"
    }
  },
  {
    name : "node-pool-2"
    version : "1.14.10-gke.34"
    min_size : 1
    max_size : 1
    instance_type : "n1-standard-2"
    volume_size : 50
    labels : {}
  }
]
