# =============================================================================
# data.tf
# -----------------------------------------------------------------------------

# =============================================================================
# VPC
# Tìm kiếm: AWS Console → VPC → Your VPCs
# =============================================================================

# Cách 1: Lookup bằng Name tag ← phổ biến nhất khi tạo thủ công
data "aws_vpc" "existing" {
  tags = {
    # Điền đúng tên bạn đã đặt khi tạo VPC trên Console
    # (cột "Name" trong danh sách VPC)
    Name = var.vpc_name_tag
  }
}

# Cách 2: Lookup bằng ID — bỏ comment nếu muốn dùng cách này
# data "aws_vpc" "existing" {
#   id = var.existing_vpc_id
# }


# Tìm Private Subnets theo tag Tier = "private"
# (nếu bạn có gắn tag này lúc tạo)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  # Bỏ comment filter theo tag nếu subnet có gắn tag
  # tags = {
  #   Tier = "private"
  # }

  # Hoặc filter theo thuộc tính: subnet KHÔNG auto-assign public IP
  filter {
    name   = "map-public-ip-on-launch"
    values = ["false"] # Private subnet thường không map public IP
  }
}

# Tìm Public Subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"] # Public subnet thường tự động gán public IP
  }
}

data "aws_iam_role" "eks_cluster" {
  # Tên chính xác của IAM Role (phân biệt hoa thường)
  # Thấy ở cột "Role name" trong AWS Console → IAM → Roles
  name = var.existing_cluster_role_name
}

data "aws_iam_role" "eks_nodes" {
  name = var.existing_node_role_name
}
