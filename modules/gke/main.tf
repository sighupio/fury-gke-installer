terraform {
  required_version = ">= 0.12.0"
  required_providers {
    google      = ">= 2.9.0"
    google-beta = ">= 2.9.0"
    kubernetes  = ">= 1.11.1"
    null        = ">= 2.1"
    random      = ">= 2.2"
    external    = "~> 2.0"
  }
}
