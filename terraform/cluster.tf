resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_node_role.name
}

# Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster_role.name
}

# Cluster
resource "aws_eks_cluster" "eks" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = "1.33"

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}

# Kubernetes provider for aws-auth mapping

data "aws_eks_cluster" "cluster" {
  depends_on = [aws_eks_cluster.eks]
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [aws_eks_cluster.eks]
  name = var.cluster_name
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

# aws-auth ConfigMap
# resource "kubernetes_config_map" "aws_auth" {
#   depends_on = [aws_eks_cluster.eks]
#   metadata {
#     name = "aws-auth"
#     namespace = "kube-system"
#   }
#   data = {
#     mapRoles = yamlencode([
#       {
#         rolearn = aws_iam_role.eks_node_role.arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups = ["system:bootstrappers", "system:nodes"]
#       }
#     ])
#     mapUsers = yamlencode([
#       {
#         userarn = "arn:aws:iam::023520667418:user/root"
#         username = "root"
#         groups = ["system:masters"]
#       },
#       {
#         userarn = "arn:aws:iam::023520667418:user/deployer"
#         username = "deployer"
#         groups = ["system:masters"]
#       }
#     ])
#   }
# }

# Node Group

resource "aws_eks_node_group" "task_nodes" {
  cluster_name = var.cluster_name
  node_group_name = "task-nodegroup"
  node_role_arn = aws_iam_role.eks_node_role.arn
  subnet_ids = aws_subnet.private[*].id
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 4
    max_size = 5
    min_size = 3
  }

  # depends_on = [kubernetes_config_map.aws_auth]

}

resource "aws_ecr_repository" "salsify-ecr" {
  name = "${var.cluster_name}-repo"
  image_tag_mutability = "IMMUTABLE"
}