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
    name      = "my-cicd-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "my-cicd-app"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "my-cicd-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-cicd-app"
        }
      }

      spec {
        container {
          name  = "tomcat"
          image = var.image
          port {
            container_port = 8080
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
    }

    port {
      port        = 8080
      target_port = 8080
      node_port   = 30080
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}
