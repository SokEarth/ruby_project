resource "aws_secretsmanager_secret" "db" {
  name = "db-app-url"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = aws_db_instance.postgres.username
    password = aws_db_instance.postgres.password
    host = aws_db_instance.postgres.address
    database = aws_db_instance.postgres.db_name
    db_url = urlencode(
      format(
        "postgres://%s:%s@%s:5432/%s",
        aws_db_instance.postgres.username,
        aws_db_instance.postgres.password,
        aws_db_instance.postgres.address,
        aws_db_instance.postgres.db_name
      )
    )
  })
}

resource "aws_iam_role" "pod_secret_access" {
  name = "pod-secret-access"
  assume_role_policy = data.aws_iam_policy_document.pod_sa_assume_role.json
}

# Get the EKS OIDC thumbprint
data "tls_certificate" "eks_cert" {
  url = format("https://%s", split("/", data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer)[2])
}

# Create OIDC provider for EKS
resource "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cert.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "pod_sa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
  }
}

resource "aws_iam_policy" "pod_secret_policy" {
  name = "pod-secret-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["secretsmanager:GetSecretValue"],
      Resource = aws_secretsmanager_secret.db.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secret_policy" {
  role = aws_iam_role.pod_secret_access.name
  policy_arn = aws_iam_policy.pod_secret_policy.arn
}

resource "kubernetes_service_account" "app_sa" {
  metadata {
    name = "app-service-account"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.pod_secret_access.arn
    }
  }
}