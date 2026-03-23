# =============================================================================
# terraform.tfvars
# -----------------------------------------------------------------------------
aws_region  = "ap-southeast-1"
environment = "production"

# ---- EKS Cluster ----
cluster_name    = "tamtm-eks-cluster"
cluster_version = "1.35"

# ---- Worker Nodes ----
node_instance_type = "t3.medium"
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 4

vpc_name_tag = "microservices-kafka-vpc"

existing_cluster_role_name = "tamtmAmazonEKSClusterRole"
existing_node_role_name    = "tamtmAmazonEKSNodeRole"
