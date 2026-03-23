# =============================================================================
# ec2_bastion.tf
# -----------------------------------------------------------------------------
# Tạo Bastion Host để SSH vào các Worker Nodes và tài nguyên trong Private Subnet.
#
# Kiến trúc:
#   Máy tính của bạn
#       │ SSH (port 22)
#       ▼
#   [Bastion Host] ← Public Subnet, có Public IP
#       │ SSH (port 22)
#       ▼
#   [Worker Nodes / Private resources] ← Private Subnet
#
# Tại sao cần Bastion Host?
#   - Worker Nodes nằm ở Private Subnet, không có Public IP
#   - Không thể SSH trực tiếp từ Internet vào Private Subnet
#   - Bastion là "cầu nối" duy nhất được phép đi vào từ ngoài
#   - Giảm attack surface: chỉ 1 điểm duy nhất expose ra Internet
# =============================================================================

# =============================================================================
# DATA SOURCE — Lấy thông tin từ VPC đã có sẵn
# (tái sử dụng data source đã khai báo trong data.tf)
# =============================================================================

# Lấy Public Subnet đầu tiên trong VPC để đặt Bastion
# (data.aws_subnets.public đã được khai báo trong data.tf)
data "aws_subnet" "bastion" {
  # Chọn subnet public đầu tiên tìm được trong VPC
  id = tolist(data.aws_subnets.public.ids)[0]
}

# Lấy AMI Amazon Linux 2023 mới nhất tự động
# → Không cần hardcode AMI ID, tự động lấy bản mới nhất theo region
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Chỉ lấy AMI chính thức từ Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023, 64-bit
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# =============================================================================
# KEY PAIR — Dùng để SSH vào Bastion
# =============================================================================

# Tạo SSH Key Pair từ public key trên máy local của bạn
# Trước khi apply, chạy: ssh-keygen -t rsa -b 4096 -f ~/.ssh/tamtm-bastion
resource "aws_key_pair" "bastion" {
  key_name = "${var.cluster_name}-bastion-key"

  # Đọc public key từ file trên máy local
  # Thay đường dẫn nếu key của bạn ở chỗ khác
  public_key = file(var.bastion_public_key_path)

  tags = { Name = "${var.cluster_name}-bastion-key" }
}

# =============================================================================
# SECURITY GROUP — Kiểm soát traffic vào/ra Bastion
# =============================================================================

resource "aws_security_group" "bastion" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Security group cho Bastion Host"
  vpc_id      = data.aws_vpc.existing.id

  # INGRESS: Chỉ cho phép SSH từ IP của bạn
  # KHÔNG mở 0.0.0.0/0 — rủi ro bị brute force rất cao
  ingress {
    description = "SSH từ IP được phép"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidrs
    # Ví dụ: ["1.2.3.4/32"] → chỉ cho phép IP 1.2.3.4
    # Tìm IP của bạn: curl ifconfig.me
  }

  # EGRESS: Cho phép Bastion SSH xuống Private Subnet
  egress {
    description = "Cho phép tất cả traffic ra ngoài"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-bastion-sg" }
}

# Cho phép Bastion SSH vào Worker Nodes (port 22)
# Thêm rule này vào Security Group của Nodes đã tạo trong security_groups.tf
resource "aws_security_group_rule" "nodes_ingress_from_bastion" {
  description              = "Cho phép Bastion SSH vào Worker Nodes"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id   # SG của nodes (security_groups.tf)
  source_security_group_id = aws_security_group.bastion.id     # Chỉ từ Bastion
}

# =============================================================================
# EC2 INSTANCE — Bastion Host
# =============================================================================

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id   # Amazon Linux 2023 mới nhất
  instance_type = var.bastion_instance_type       # t3.micro là đủ cho Bastion

  # Đặt vào Public Subnet để có thể nhận Public IP từ Internet
  subnet_id = data.aws_subnet.bastion.id

  # Gán Security Group cho phép SSH từ IP bạn khai báo
  vpc_security_group_ids = [aws_security_group.bastion.id]

  # Gán Key Pair để SSH bằng private key tương ứng
  key_name = aws_key_pair.bastion.key_name

  # Tự động cấp Public IP (cần thiết để SSH từ Internet vào)
  associate_public_ip_address = true

  # Script chạy lần đầu khi instance khởi động
  # Cài kubectl để có thể quản lý EKS cluster từ Bastion
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Cập nhật hệ thống
    yum update -y

    # Cài kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/

    # Cài AWS CLI v2 (thường đã có sẵn trên Amazon Linux 2023)
    # Dùng để chạy: aws eks update-kubeconfig

    echo "Bastion Host ready!" >> /var/log/bastion-init.log
  EOF

  # Bảo vệ khỏi xóa nhầm bằng terraform destroy
  # Đổi thành false nếu muốn xóa được
  disable_api_termination = var.bastion_termination_protection

  tags = {
    Name = "${var.cluster_name}-bastion"
    Role = "bastion"
  }
}

# =============================================================================
# ELASTIC IP — IP tĩnh cho Bastion (tùy chọn)
# -----------------------------------------------------------------------------
# Không có EIP: Public IP thay đổi mỗi lần stop/start instance
# Có EIP: IP cố định, tiện hơn khi cấu hình firewall/whitelist
# Lưu ý: EIP tính phí khi instance đang STOP (~$0.005/giờ)
# =============================================================================

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = { Name = "${var.cluster_name}-bastion-eip" }
}
