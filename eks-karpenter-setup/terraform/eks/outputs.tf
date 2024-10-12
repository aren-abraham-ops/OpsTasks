output "cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}
output "cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}
output "node_group_role_arn" {
  description = "IAM Role ARN for EKS node groups"
  value       = aws_iam_role.eks_node_role.arn
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}