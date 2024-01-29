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

resource "grafana_slo" "test-server_latency" {
  name        = "(Terraform) Test Server HTTP Latency"
  description = "99.5% of Test Server Requests are below 25ms"
  query {
    ratio {
      success_metric  = "app_request_latency_seconds_bucket{le=\"0.025\"}"
      total_metric    = "app_request_latency_seconds_count"
    #   group_by_labels = ["endpoint"]
    }
    type = "ratio"
  }
  objectives {
    value  = 0.995
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

resource "grafana_slo" "test-server_availability_grafana_mimir" {
  name        = "(Terraform) (Grafana Mimir) Test Server HTTP Availability"
  description = "99.9% of Test Server Requests are not 5xx errors"
  query {
    ratio {
      success_metric  = "app_request_count_total{job=\"app\", http_status=\"200\"}"
      total_metric    = "app_request_count_total{job=\"app\"}"
      # group_by_labels = ["job", "instance"]
    }
    type = "ratio"
  }
  objectives {
    value  = 0.999
    window = "7d"
  }
   destination_datasource { 
      uid = "grafanacloud-prom" 
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
}

resource "grafana_slo" "test-server_latency_grafana_mimir" {
  name        = "(Terraform) (Grafana Mimir) Test Server HTTP Latency"
  description = "99.5% of Test Server Requests are below 25ms"
  query {
    ratio {
      success_metric  = "app_request_latency_seconds_bucket{le=\"0.025\"}"
      total_metric    = "app_request_latency_seconds_count"
    #   group_by_labels = ["endpoint"]
    }
    type = "ratio"
  }
  objectives {
    value  = 0.995
    window = "7d"
  }
   destination_datasource { 
      uid = "grafanacloud-prom" 
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
}