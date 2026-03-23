# =============================================================================
# outputs.tf
# Thêm các output để verify đúng VPC/IAM được tìm thấy
# =============================================================================

# ---- Verify VPC tìm đúng chưa ----
output "vpc_found" {
  description = "VPC đã tìm được — kiểm tra lại xem đúng chưa"
  value = {
    id   = data.aws_vpc.existing.id
    cidr = data.aws_vpc.existing.cidr_block
    tags = data.aws_vpc.existing.tags
  }
}

output "private_subnets_found" {
  description = "Danh sách Private Subnet IDs tìm được"
  value       = data.aws_subnets.private.ids
}

output "public_subnets_found" {
  description = "Danh sách Public Subnet IDs tìm được"
  value       = data.aws_subnets.public.ids
}

# ---- Verify IAM Role tìm đúng chưa ----
output "cluster_role_found" {
  description = "IAM Role của EKS Cluster — kiểm tra ARN"
  value       = data.aws_iam_role.eks_cluster.arn
}

output "node_role_found" {
  description = "IAM Role của Worker Nodes — kiểm tra ARN"
  value       = data.aws_iam_role.eks_nodes.arn
}

# ---- EKS Cluster sau khi tạo ----
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}
