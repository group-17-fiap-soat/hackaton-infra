resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = "default"
  }
  data = {
    "prometheus.yml" = <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["prometheus-server.default.svc.cluster.local:9090"]
EOF
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "default"
    labels = {
      app = "prometheus"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.53.0"
          args  = ["--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus"]
          port {
            container_port = 9090
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/prometheus"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus_server" {
  metadata {
    name      = "prometheus-server"
    namespace = "default"
    labels = {
      app = "prometheus"
    }
  }
  spec {
    selector = {
      app = "prometheus"
    }
    port {
      name        = "http"
      port        = 9090
      target_port = 9090
    }
    type = "ClusterIP"
  }
}

resource "helm_release" "grafana" {
  depends_on         = [kubernetes_service.prometheus_server]
  name               = "grafana"
  repository         = "https://grafana.github.io/helm-charts"
  chart              = "grafana"
  namespace          = "default"
  create_namespace   = false
  wait               = false
  timeout            = 1800
  replace            = true
  cleanup_on_fail    = true
  dependency_update  = true
  values = [<<EOF
adminUser: admin
adminPassword: admin
persistence:
  enabled: false
rbac:
  create: false
service:
  type: LoadBalancer
serviceAccount:
  create: false
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-server.default.svc.cluster.local
        access: proxy
        isDefault: true
EOF
  ]
}
