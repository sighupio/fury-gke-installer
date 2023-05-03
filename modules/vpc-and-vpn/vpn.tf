data "external" "os" {
  program = ["${path.module}/bin/os.sh"]
}

locals {
  os                     = data.external.os.result.os
  local_furyagent        = local.os == "Darwin" ? "${path.module}/bin/furyagent-darwin-amd64" : "${path.module}/bin/furyagent-linux-amd64"
  openvpn_subnets_routes = [for subnet in local.subnets : { "network" : cidrhost(subnet.subnet_ip, 0), "netmask" : cidrnetmask(subnet.subnet_ip) }]
  openvpn_routes         = concat(local.openvpn_subnets_routes, [{ "network" : cidrhost(var.cluster_control_plane_cidr_block, 0), "netmask" : cidrnetmask(var.cluster_control_plane_cidr_block) }])

  vpntemplate_vars = {
    openvpn_port           = var.vpn_port,
    openvpn_subnet_network = cidrhost(var.vpn_subnetwork_cidr, 0),
    openvpn_subnet_netmask = cidrnetmask(var.vpn_subnetwork_cidr),
    openvpn_routes         = local.openvpn_routes,
    openvpn_dhparam_bits   = var.vpn_dhparams_bits,
    furyagent_version      = "v0.2.2"
    google_service_account = indent(6, base64decode(google_service_account_key.furyagent_server.private_key))
    furyagent              = indent(6, local.furyagent_server),
  }

  furyagent_server_vars = {
    bucketName        = google_storage_bucket.furyagent.name,
    google_project_id = data.google_client_config.this.project,
    servers           = [for serverIP in google_compute_address.vpn.*.address : "${serverIP}:${var.vpn_port}"]
    user              = var.vpn_operator_name,
  }

  furyagent_client_vars = {
    bucketName             = google_storage_bucket.furyagent.name,
    google_service_account = abspath("${path.root}/secrets/gcp-sa.json"),
    google_project_id      = data.google_client_config.this.project,
    servers                = [for serverIP in google_compute_address.vpn.*.address : "${serverIP}:${var.vpn_port}"]
    user                   = var.vpn_operator_name,
  }
  furyagent_server = templatefile("${path.module}/templates/furyagent-server.yml", local.furyagent_server_vars)
  furyagent_client = templatefile("${path.module}/templates/furyagent-client.yml", local.furyagent_client_vars)
  users            = var.vpn_ssh_users
  sshkeys_vars = {
    users = local.users
  }
  sshkeys = templatefile("${path.module}/templates/ssh-users.yml", local.sshkeys_vars)
}

//INSTANCE RELATED STUFF
resource "google_compute_firewall" "vpn" {
  name    = "${var.name}-vpn"
  network = module.vpc.network_name

  allow {
    protocol = "udp"
    ports    = [var.vpn_port]
  }

  target_tags = ["vpn"]
}

resource "google_compute_firewall" "icmp" {
  name    = "${var.name}-icmp"
  network = module.vpc.network_name

  allow {
    protocol = "icmp"
  }

  target_tags = ["icmp"]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-ssh"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = var.vpn_operator_cidrs
  target_tags   = ["ssh"]
}


resource "google_compute_address" "vpn" {
  count = var.vpn_instances
  name  = "${var.name}-${count.index}"
}

data "google_compute_zones" "available" {
}

resource "google_compute_instance" "this" {
  count                     = var.vpn_instances
  name                      = "${var.name}-${count.index + 1}"
  machine_type              = var.vpn_instance_type
  allow_stopping_for_update = true
  zone                      = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  can_ip_forward = true
  labels         = var.tags
  tags           = ["ssh", "icmp", "vpn"]

  boot_disk {
    initialize_params {
      size  = var.vpn_instance_disk_size
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = local.public_subnets[count.index % length(local.public_subnets)].subnet_name

    access_config {
      nat_ip = google_compute_address.vpn[count.index].address
    }
  }

  metadata = {
    user-data = templatefile(
      "${path.module}/templates/vpn.yml",
      merge(
        local.vpntemplate_vars, {
          openvpn_dns_servers = [cidrhost(local.public_subnets[count.index % length(local.public_subnets)].subnet_ip, 1)]
        }
      )
    )
  }
}

// BUCKET AND IAM
resource "random_string" "furyagent" {
  length  = 10
  upper   = false
  special = false
}

resource "google_storage_bucket" "furyagent" {
  name          = "${var.name}-furyagent-${random_string.furyagent.result}"
  force_destroy = true
  project       = data.google_client_config.this.project
  location      = data.google_client_config.this.region
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  labels = var.tags
}

resource "google_service_account" "furyagent_server" {
  account_id   = "${var.name}-furyagent-server"
  display_name = "${var.name} furyagent Service Account"
}

resource "google_service_account" "furyagent_client" {
  account_id   = "${var.name}-furyagent-client"
  display_name = "${var.name} furyagent Service Account"
}

resource "google_storage_bucket_iam_member" "furyagent_server" {
  bucket = google_storage_bucket.furyagent.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.furyagent_server.email}"
}

resource "google_storage_bucket_iam_member" "furyagent_client" {
  bucket = google_storage_bucket.furyagent.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.furyagent_client.email}"
}

resource "google_service_account_key" "furyagent_server" {
  service_account_id = google_service_account.furyagent_server.name
}

resource "google_service_account_key" "furyagent_client" {
  service_account_id = google_service_account.furyagent_client.name
}


//FURYAGENT

resource "local_file" "furyagent_client" {
  content  = local.furyagent_client
  filename = "${path.root}/secrets/furyagent.yml"

  depends_on = [local_file.google_service_account_key]
}

resource "local_file" "google_service_account_key" {
  content  = base64decode(google_service_account_key.furyagent_client.private_key)
  filename = "${path.root}/secrets/gcp-sa.json"
}

resource "local_file" "sshkeys" {
  content  = local.sshkeys
  filename = "${path.root}/ssh-users.yml"
}

resource "null_resource" "init" {
  triggers = {
    "init" : "just-once",
  }
  provisioner "local-exec" {
    command = "until `${local.local_furyagent} init openvpn --config ${local_file.furyagent_client.filename}`; do echo \"Retrying\"; sleep 30; done" # Required because of gcp iam lag
  }

  depends_on = [local_file.furyagent_client]
}

resource "null_resource" "ssh_users" {
  triggers = {
    "sync-users" : join(",", local.users),
    "sync-operator" : var.vpn_operator_name
  }
  provisioner "local-exec" {
    command = "until `${local.local_furyagent} init ssh-keys --config ${local_file.furyagent_client.filename}`; do echo \"Retrying\"; sleep 30; done" # Required because of aws iam lag
  }
  depends_on = [local_file.sshkeys,
    local_file.furyagent_client
  ]
}
