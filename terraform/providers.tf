terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

# Provider ini membaca kubeconfig lokal kamu (hasil dari minikube/kind/docker-desktop)
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}
