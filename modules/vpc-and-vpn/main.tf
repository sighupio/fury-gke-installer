data "google_client_config" "this" {}

terraform {
  required_version = ">= 1.3"
  required_providers {
    external = "~>2.3"
    google   = "~>3.90"
    local    = "~>2.4"
    null     = "~>3.2"
    random   = "~>3.5"
  }
}
