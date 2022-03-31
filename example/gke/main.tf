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
    os : "COS" # to select a particular OS image, optional. Default: COS: Container-Optimized OS
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
    spot_instance : true # create preemptible instances instead of the standard ones, optional
  }
  ]

}

data "google_client_config" "current" {}
