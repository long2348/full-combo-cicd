# =============================================================================
# eks.tf
# =============================================================================

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = concat(
      data.aws_subnets.public.ids,   # ← từ data source
      data.aws_subnets.private.ids   # ← từ data source
    )
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = { Name = var.cluster_name }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = data.aws_iam_role.eks_nodes.arn
  subnet_ids      = data.aws_subnets.private.ids # ← từ data source
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = { Name = "${var.cluster_name}-nodes" }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# =============================================================================
# eks.tf
# =============================================================================

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = concat(
      data.aws_subnets.public.ids,   # ← từ data source
      data.aws_subnets.private.ids   # ← từ data source
    )
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = { Name = var.cluster_name }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = data.aws_iam_role.eks_nodes.arn
  subnet_ids      = data.aws_subnets.private.ids # ← từ data source
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = { Name = "${var.cluster_name}-nodes" }

  depends_on = [
    data.aws_iam_role.eks_cluster,
    data.aws_iam_role.eks_nodes,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

