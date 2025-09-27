terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.24.0" }
    helm = { source = "hashicorp/helm", version = ">= 3.0.0" } # v3 mudou sintaxe
    grafana = { source = "grafana/grafana", version = ">= 2.0.0" }
    http = { source = "hashicorp/http", version = ">= 3.0.0" }
  }
}

provider "aws" {
  region = var.aws_region
}
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "grafana" {
  url  = "http://grafana.monitoring.svc.cluster.local"
  auth = "admin:admin" # em prod usa token/API key pls
}