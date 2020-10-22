terraform {
  required_version = ">= 0.12.0"
  required_providers {
    google      = ">= 3.44.0"
    google-beta = ">= 3.44.0"
    kubernetes  = ">= 1.13.2"
    null        = ">= 3.0.0"
    random      = ">= 3.0.0"
    external    = ">= 2.0.0"
  }
}
