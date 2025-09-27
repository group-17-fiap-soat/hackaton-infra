provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "grafana" {
  url  = "http://grafana.monitoring.svc.cluster.local"
  auth = "admin:admin"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
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

  required_version = ">= 1.5"
}
