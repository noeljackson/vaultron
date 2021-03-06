#############################################################################
# Yellow Lion
# Vault telemetry stack
# statsd, graphite, Grafana
#############################################################################

# Variables

variable "grafana_version" {}
variable "statsd_version" {}
variable "vaultron_telemetry_count" {}

# statsd/graphite image and container

resource "docker_image" "statsd" {
  count        = "${var.vaultron_telemetry_count}"
  name         = "graphiteapp/graphite-statsd:${var.statsd_version}"
  keep_locally = true
}

resource "docker_container" "statsd_graphite" {
  count = "${var.vaultron_telemetry_count}"
  name  = "vstatsd"
  image = "${docker_image.statsd.latest}"
  must_run = true
  restart = "always"

  ports {
    internal = "80"
    external = "80"
    protocol = "tcp"
  }

  ports {
    internal = "2003"
    external = "2003"
    protocol = "tcp"
  }

  ports {
    internal = "2004"
    external = "2004"
    protocol = "tcp"
  }

  ports {
    internal = "2023"
    external = "2023"
    protocol = "tcp"
  }

  ports {
    internal = "2024"
    external = "2024"
    protocol = "tcp"
  }

  ports {
    internal = "8125"
    external = "8125"
    protocol = "udp"
  }

  ports {
    internal = "8126"
    external = "8126"
    protocol = "tcp"
  }

}

output "statsd_ip" {
  value = "${docker_container.statsd_graphite.*.ip_address}"
}

# Grafana image and container

resource "docker_image" "grafana" {
  count        = "${var.vaultron_telemetry_count}"
  name         = "grafana/grafana:${var.grafana_version}"
  keep_locally = true
}

# Grafana container resource
resource "docker_container" "grafana" {
  count        = "${var.vaultron_telemetry_count}"
  name  = "vgrafana"
  image = "${docker_image.grafana.latest}"
  env   = ["GF_SECURITY_ADMIN_PASSWORD=vaultron"]
  env   = ["GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource"]

  volumes {
    host_path      = "${path.module}/../../../grafana/data"
    container_path = "/var/lib/grafana"
  }

  must_run = true

  ports {
    internal = "3000"
    external = "3000"
    protocol = "tcp"
  }
}
