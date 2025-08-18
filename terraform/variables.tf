variable "namespace" {
  type    = string
  default = "my-cicd"
}

variable "image" {
  type    = string
  default = "terrytan0125/my_cicd_proj:latest"
}

variable "kubeconfig_path" {
  type    = string
  default = "/home/jenkins/.kube/config"
}

variable "nodeport" {
  type    = string
  default = "30080"
}
