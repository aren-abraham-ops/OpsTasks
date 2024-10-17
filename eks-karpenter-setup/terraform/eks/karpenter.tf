# # Install Karpenter using Helm
# resource "helm_release" "karpenter" {
#   name             = "karpenter"
#   repository       = "https://charts.karpenter.sh"
#   chart            = "karpenter"
#   version          = "0.16.3"
#   namespace        = "karpenter"
#   create_namespace = true

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "clusterEndpoint"
#     value = module.eks.cluster_endpoint
#   }

#   set {
#     name  = "awsRegion"
#     value = var.aws_region
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.karpenter_role.arn
#   }
# }

# # Define IAM Role for Karpenter
# resource "aws_iam_role" "karpenter_role" {
#   name = "karpenter-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # Attach necessary policies to the Karpenter role
# resource "aws_iam_role_policy_attachment" "karpenter_policy" {
#   role       = aws_iam_role.karpenter_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_node_policy" {
#   role       = aws_iam_role.karpenter_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_cni_policy" {
#   role       = aws_iam_role.karpenter_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
#   role       = aws_iam_role.karpenter_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# # Metric server
# resource "helm_release" "metrics_server" {
#   name             = "metrics-server"
#   repository       = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart            = "metrics-server"
#   version          = "3.10.0"
#   namespace        = "kube-system"
#   create_namespace = false

#   set {
#     name  = "args"
#     value = "{--kubelet-insecure-tls=true}"
#   }

#   set {
#     name  = "resources.limits.cpu"
#     value = "100m"
#   }

#   set {
#     name  = "resources.limits.memory"
#     value = "200Mi"
#   }
# } 
