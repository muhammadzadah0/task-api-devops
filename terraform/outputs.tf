output "app_url" {
  value = "http://localhost:${var.app_port}"
}

output "grafana_url" {
  value = "http://localhost:3000"
}

output "prometheus_url" {
  value = "http://localhost:9090"
}
