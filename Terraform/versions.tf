terraform {
  # Yêu cầu Terraform >= 1.3.0 vì dùng các tính năng mới như moved block
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Cho phép 5.0, 5.1, 5.x ... nhưng không lên 6.0
    }
  }

  # -----------------------------------------------------------------------------
  # (Tùy chọn) Lưu Terraform State vào S3 thay vì local
  # Bỏ comment phần này khi làm việc theo nhóm để tránh conflict state
  # -----------------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "eks/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   encrypt        = true         # Mã hóa state file
  #   dynamodb_table = "terraform-lock" # Khóa để tránh 2 người apply cùng lúc
  # }
}

# =============================================================================
# Provider Configuration
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Project     = var.cluster_name
      Environment = var.environment
    }
  }
}
