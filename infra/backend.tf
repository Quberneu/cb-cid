terraform {
  backend "gcs" {
    bucket = "tf-state-cb-cid"
    prefix = "terraform/state"
  }
}
