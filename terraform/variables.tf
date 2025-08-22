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

variable "reps" {
  type    = string
  default = "1"
}
variable "canary_reps" { default = 1 }
variable "enable_canary" { default = false }
