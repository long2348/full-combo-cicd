# =============================================================================
# variables_bastion.tf
# -----------------------------------------------------------------------------
# Các biến bổ sung cho Bastion Host.
# Thêm các giá trị tương ứng vào terraform.tfvars
# =============================================================================

variable "bastion_instance_type" {
  description = <<-EOT
    Loại EC2 cho Bastion Host.
    Bastion chỉ làm nhiệm vụ SSH tunnel nên không cần mạnh:
      - t3.micro  : Đủ dùng, nằm trong Free Tier
      - t3.small  : Nếu cần chạy thêm script nặng hơn
  EOT
  type        = string
  default     = "t3.micro"
}

variable "bastion_public_key_path" {
  description = <<-EOT
    Đường dẫn đến file PUBLIC key (.pub) trên máy local của bạn.
    Tạo key pair nếu chưa có:
      ssh-keygen -t rsa -b 4096 -f ~/.ssh/tamtm-bastion
    Sau đó truyền đường dẫn file .pub vào đây.
  EOT
  type        = string
  default     = "~/.ssh/tamtm-bastion.pub"
}

variable "bastion_allowed_cidrs" {
  description = <<-EOT
    Danh sách IP được phép SSH vào Bastion (định dạng CIDR).
    KHÔNG dùng 0.0.0.0/0 — rủi ro bị tấn công rất cao.
    Tìm IP hiện tại của bạn: curl ifconfig.me
    Ví dụ: ["203.0.113.10/32", "203.0.113.20/32"]
  EOT
  type        = list(string)
  # Không có default → BẮT BUỘC phải điền vào terraform.tfvars
}

variable "bastion_termination_protection" {
  description = "Bật/tắt bảo vệ xóa nhầm Bastion bằng terraform destroy hoặc Console"
  type        = bool
  default     = true
}
