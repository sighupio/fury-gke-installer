data "google_client_config" "this" {}

provider "local" {
  version = "2.0.0"
}

provider "null" {
  version = "3.0.0"
}

provider "external" {
  version = "2.0.0"
}

provider "random" {
  version = "3.0.1"
}

provider "google" {
  version = "3.55.0"
}
