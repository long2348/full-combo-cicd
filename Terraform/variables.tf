# =============================================================================
# variables.tf
# =============================================================================

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "cluster_name" {
  type    = string
  default = "tamtm-eks-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.35"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "vpc_name_tag" {
  description = "Giá trị tag Name của VPC"
  type        = string
  default     = "microservices-kafka-vpc"
}

# Dùng nếu muốn lookup bằng ID thay vì tag Name
# variable "existing_vpc_id" {
#   description = "Giá trị id của VPC"
#   type        = string
#   default     = ""
# }

variable "existing_cluster_role_name" {
  description = "Cluster role name"
  type        = string
  default = "tamtmAmazonEKSClusterRole"
}

variable "existing_node_role_name" {
  description = "node worker role name"
  type        = string
  default = "tamtmAmazonEKSNodeRole"
}
