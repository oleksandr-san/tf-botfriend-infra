terraform {
  backend "gcs" {
    bucket = "devopsigl1"
    prefix = "terraform/state"
  }
}
