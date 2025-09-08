resource "kubernetes_namespace" "external_secrets" {
  depends_on = [aws_eks_node_group.task_nodes]
  metadata { name = "external-secrets" }
}

resource "helm_release" "external_secrets" {
  depends_on = [kubernetes_namespace.external_secrets]
  name = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart = "external-secrets"
  namespace = "external-secrets"

  create_namespace = true
}


resource "kubernetes_manifest" "aws_secretstore" {
  depends_on = [helm_release.external_secrets]
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind = "SecretStore"
    metadata = {
      name = "aws-secret-store",
      namespace = "default"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region = "eu-north-1"
          auth = {
            jwt = {
              serviceAccountRef = { name = "app-service-account" }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "app_db_secret" {
  depends_on = [kubernetes_manifest.aws_secretstore]
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind = "ExternalSecret"
    metadata = { 
      name = "app-db-secret", 
      namespace = "default" 
    }
    spec = {
      refreshInterval = "1m"
      secretStoreRef = {
        name = "aws-secret-store",
        kind = "SecretStore"
      }
      target = {
        name = "app-db-secret",
        creationPolicy = "Owner"
      }
      data = [
        {
        secretKey = "DB_USERNAME"
        remoteRef = {
          key = aws_secretsmanager_secret.db.name,
          property = "username"
        }
        },
        {
          secretKey = "DB_PASSWORD"
          remoteRef = {
            key = aws_secretsmanager_secret.db.name,
            property = "password" 
          }
        },
        {
          secretKey = "DB_HOST"
          remoteRef = {
            key = aws_secretsmanager_secret.db.name,
            property = "host"
          }
        },
        {
          secretKey = "DATABASE_URL"
          remoteRef = {
            key = aws_secretsmanager_secret.db.name,
            property = "db_url"
          }
        },
        {
          secretKey = "DB_NAME"
          remoteRef = {
            key = aws_secretsmanager_secret.db.name,
            property = "database"
          }
        },
        {
          secretKey = "RACK_ENV"
          remoteRef = {
            key = aws_secretsmanager_secret.db.name,
            property = "rack_env"
          }
        },
        {
          secretKey = "GIFMACHINE_PASSWORD"
          remoteRef = {
            key = aws_secretsmanager_secret.db.name,
            property = "gifmachine_password"
          }
        }
      ]
    }
  }
}
