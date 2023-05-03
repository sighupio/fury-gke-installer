terraform {
  required_version = ">=1.3.0"
  required_providers {
    google      = "~>3.63.0"
    google-beta = "~>3.63.0"
    kubernetes  = "~>1.13.4"
    null        = "~>3.1.1"
    random      = "~>3.1.0"
    external    = "~>2.1.0"
  }
}
