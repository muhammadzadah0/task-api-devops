terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "task-api-network"
}

resource "docker_volume" "postgres_data" {
  name = "task-api-postgres-data"
}

resource "docker_volume" "prometheus_data" {
  name = "task-api-prometheus-data"
}

resource "docker_volume" "grafana_data" {
  name = "task-api-grafana-data"
}

resource "docker_container" "db" {
  name  = "tasks_db"
  image = "postgres:15-alpine"
  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]
  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.db_user} -d ${var.db_name}"]
    interval = "5s"
    timeout  = "5s"
    retries  = 5
  }
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
}

resource "docker_image" "app" {
  name = "task-api:${var.image_tag}"
  build {
    context    = abspath("${path.module}/..")
    dockerfile = "${abspath(path.module)}/../Dockerfile"
    tag        = ["task-api:${var.image_tag}"]
  }
}

resource "docker_container" "app" {
  name  = "tasks_api"
  image = docker_image.app.name
  ports {
    internal = 8000
    external = var.app_port
  }
  env = [
    "DB_HOST=${docker_container.db.name}",
    "DB_PORT=5432",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "PORT=8000"
  ]
  networks_advanced {
    name = docker_network.app_network.name
  }
  depends_on = [docker_container.db]
}

resource "docker_container" "prometheus" {
  name  = "tasks_prometheus"
  image = "prom/prometheus:v2.53.0"
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = "${abspath(path.module)}/../prometheus"
    container_path = "/etc/prometheus"
  }
  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
}

resource "docker_container" "grafana" {
  name  = "tasks_grafana"
  image = "grafana/grafana:11.1.0"
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=admin"
  ]
  volumes {
    host_path      = "${abspath(path.module)}/../grafana/provisioning"
    container_path = "/etc/grafana/provisioning"
  }
  volumes {
    host_path      = "${abspath(path.module)}/../grafana/dashboards"
    container_path = "/var/lib/grafana/dashboards"
  }
  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
}
