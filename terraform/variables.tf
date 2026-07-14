variable "kubeconfig_path" {
  description = "Path ke file kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Nama context kubeconfig yang dipakai (mis. minikube, kind-kind)"
  type        = string
  default     = "minikube"
}

variable "namespace" {
  description = "Namespace Kubernetes untuk aplikasi"
  type        = string
  default     = "devops-learning"
}

variable "app_image" {
  description = "Docker image yang akan dideploy"
  type        = string
  default     = "devops-learning-project:local"
}

variable "replicas" {
  description = "Jumlah replica pod"
  type        = number
  default     = 2
}

variable "app_version" {
  description = "Versi aplikasi (untuk env var APP_VERSION)"
  type        = string
  default     = "1.0.0"
}
