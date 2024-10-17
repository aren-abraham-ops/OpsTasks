provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {}
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids
  enable_irsa     = true

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name               = "${var.cluster_name}-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role_policy.json
}

data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Add the CoreDNS add-on
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.11.3-eksbuild.1"
}

# Add the VPC CNI add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.18.5-eksbuild.1" 
}

# Add the AWS EBS CSI Driver add-on
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.35.0-eksbuild.1" 
  service_account_role_arn    = aws_iam_role.ebs_csi_driver_role.arn
}

# Add the kube-proxy add-on
resource "aws_eks_addon" "kube_proxy" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.31.0-eksbuild.5" 
}


resource "aws_eks_node_group" "x86_node_group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "x86-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]
  ami_type        = "AL2_x86_64"

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  tags = {
    Environment = var.environment
  }
}

# ARM64 node group for Graviton instances
resource "aws_eks_node_group" "arm64_node_group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "arm64-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["m5g.medium"]
  ami_type        = "AL2_ARM_64"

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  tags = {
    Environment = var.environment
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        "rolearn" : aws_iam_role.eks_node_role.arn,
        "username" : "system:node:{{EC2PrivateDNSName}}",
        "groups" : ["system:bootstrappers", "system:nodes"]
      }
    ])

    mapUsers = jsonencode([
      {
        "userarn" : "arn:aws:iam::954010472300:user/terraform",
        "username" : "terraform",
        "groups" : ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks]
}
