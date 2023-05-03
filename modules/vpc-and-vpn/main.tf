data "google_client_config" "this" {}

terraform {
  required_version = ">=1.3.0"
  required_providers {
    local    = "~>2.1.0"
    null     = "~>3.1.1"
    external = "~>2.1.1"
    random   = "~>3.1.3"
    google   = "~>3.63.0"
  }
}
