data "google_client_config" "this" {}

terraform {
  required_version = "0.15.4"
  required_providers {
    local    = "2.0.0"
    null     = "3.0.0"
    external = "2.0.0"
    random   = "3.0.1"
    google   = "3.55.0"
  }
}
