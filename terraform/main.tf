terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "webapp" {
  metadata {
    name      = "my-cicd-main"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "my-cicd-app"
      tier = "main"
    }
  }

  spec {
    replicas = var.reps
    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = 1
        max_surge       = 1
      }
    }
    selector {
      match_labels = {
        app = "my-cicd-app"
	tier = "main"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-cicd-app"
	  tier = "main"
        }
      }

      spec {
        container {
          name  = "tomcat"
          image = var.image
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

# Canary Deployment
resource "kubernetes_deployment" "webapp_canary" {
  count = var.enable_canary ? 1 : 0

  metadata {
    name      = "my-cicd-canary"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app  = "my-cicd-app"
      tier = "canary"
    }
  }

  spec {
    replicas = var.canary_reps

    selector {
      match_labels = {
        app  = "my-cicd-app"
        tier = "canary"
      }
    }

    template {
      metadata {
        labels = {
          app  = "my-cicd-app"
          tier = "canary"
        }
      }

      spec {
        container {
          name  = "tomcat"
          image = var.image
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webapp" {
  metadata {
    name      = "my-cicd-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "my-cicd-app"
#      tier = "main"
    }

    port {
      port        = 8080
      target_port = 8080
      node_port   = var.nodeport
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}
