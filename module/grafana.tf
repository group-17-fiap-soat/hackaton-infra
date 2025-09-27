resource "helm_release" "prometheus" {
  name              = "prometheus-min"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "prometheus"
  namespace         = "default"
  create_namespace  = false
  wait              = false
  timeout           = 1200
  replace           = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [<<EOF
alertmanager:
  enabled: false
pushgateway:
  enabled: false
kubeStateMetrics:
  enabled: false
nodeExporter:
  enabled: false
server:
  persistentVolume:
    enabled: false
  service:
    type: ClusterIP
rbac:
  create: false
EOF
  ]
}

resource "helm_release" "grafana" {
  depends_on        = [helm_release.prometheus]
  name              = "grafana"
  repository        = "https://grafana.github.io/helm-charts"
  chart             = "grafana"
  namespace         = "default"
  create_namespace  = false
  wait              = false
  timeout           = 1800
  replace           = true
  cleanup_on_fail   = true
  dependency_update = true

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
