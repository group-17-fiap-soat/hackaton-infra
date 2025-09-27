terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.24.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">=2.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "grafana" {
  url  = "http://grafana.monitoring.svc.cluster.local"
  auth = "admin:admin"
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  values = [<<EOF
adminUser: admin
adminPassword: admin
persistence:
  enabled: true
  size: 5Gi
service:
  type: ClusterIP
EOF
  ]
}

resource "grafana_data_source" "prometheus" {
  depends_on = [helm_release.grafana]

  name       = "Prometheus"
  type       = "prometheus"
  url        = "http://prometheus-server.monitoring.svc.cluster.local"
  access     = "proxy"
  is_default = true
}

data "http" "node_dash" {
  url = "https://grafana.com/api/dashboards/1860/revisions/32/download"
}

resource "grafana_dashboard" "nodes" {
  depends_on  = [grafana_data_source.prometheus]
  config_json = data.http.node_dash.response_body
}
