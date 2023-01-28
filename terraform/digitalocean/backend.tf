terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "francrodriguez"
    workspaces {
      name = "francrodriguezcom-infra"
    }
  }
}
