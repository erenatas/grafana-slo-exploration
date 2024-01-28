# https://registry.terraform.io/providers/grafana/grafana/latest/docs
terraform {
    required_providers {
        grafana = {
            source = "grafana/grafana"
            version = ">= 2.5.0"
        }
    }
}

provider "grafana" {
    url  = var.GRAFANA_URL
    auth = var.GRAFANA_AUTH_TOKEN
}