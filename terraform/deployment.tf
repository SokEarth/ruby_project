resource "kubernetes_deployment" "app" {
  metadata { 
    name = "demo-app"
    namespace = "default" 
  }
  spec {
    replicas = 1
    selector { 
      match_labels = { 
        app = "demo-app"
      }
    }
    template {
      metadata {
        labels = { 
          app = "demo-app" 
        }
      }
      spec {
        service_account_name = "app-service-account"
        container {
          name = "demo-app"
          image = "023520667418.dkr.ecr.eu-north-1.amazonaws.com/salsify-task-repo:gitmachine-b1b89806e978e13e09f8d24f29906826ff87b1fe"
          env {
            name = "DB_USERNAME"
            value_from { 
              secret_key_ref { 
                name = "app-db-secret"
                key = "DB_USERNAME"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from { 
              secret_key_ref {
                name = "app-db-secret"
                key = "DB_PASSWORD"
              }
            }
          }
          env {
            name = "DB_HOST"
            value_from { 
              secret_key_ref { 
                name = "app-db-secret"
                key = "DB_HOST"
              }
            }
          }
          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = "app-db-secret"
                key = "DATABASE_URL"
              }
            }
          }
          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref { 
                name = "app-db-secret"
                key = "DB_NAME"
              }
            }
          }
          env {
            name = "RACK_ENV"
            value_from {
              secret_key_ref { 
                name = "app-db-secret"
                key = "RACK_ENV"
              }
            }
          }
          env {
            name = "GIFMACHINE_PASSWORD"
            value_from {
              secret_key_ref { 
                name = "app-db-secret"
                key = "GIFMACHINE_PASSWORD"
              }
            }
          }
        
          resources {
            requests = { 
              memory = "200Mi",
              cpu = "150m"
            }
            limits = {
              memory = "300Mi",
              cpu = "300m"
            }
          }
        }
      }
    }
  }
}