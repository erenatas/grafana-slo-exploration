# https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/slo
resource "grafana_slo" "test-server_availability" {
  name        = "(Terraform) Test Server HTTP Availability"
  description = "99.9% of Test Server Requests are not 5xx errors"
  query {
    ratio {
      success_metric  = "app_request_count_total{job=\"prometheus.scrape.app\", http_status=\"200\"}"
      total_metric    = "app_request_count_total{job=\"prometheus.scrape.app\"}"
      # group_by_labels = ["job", "instance"]
    }
    type = "ratio"
  }
  objectives {
    value  = 0.999
    window = "7d"
  }
   destination_datasource { 
      uid = "demo-mimir" 
  }
  label {
    key   = "slo"
    value = "terraform"
  }
  alerting {
    fastburn {
      annotation {
        key   = "name"
        value = "SLO Burn Rate Very High"
      }
      annotation {
        key   = "description"
        value = "Error budget is burning too fast"
      }
    }

    slowburn {
      annotation {
        key   = "name"
        value = "SLO Burn Rate High"
      }
      annotation {
        key   = "description"
        value = "Error budget is burning too fast"
      }
    }
  }

  depends_on = [
    grafana_data_source.prometheus
  ]
}