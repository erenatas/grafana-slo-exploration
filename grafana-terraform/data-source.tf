# https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source
resource "grafana_data_source" "prometheus" {
  type                = "prometheus"
  name                = "(Terraform) demo-mimir"
  uid                 = "demo-mimir"
  url = var.MIMIR_URL
  basic_auth_enabled  = false
}