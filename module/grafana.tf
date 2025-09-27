


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
