# =============================================================================
# outputs_bastion.tf
# =============================================================================

output "bastion_public_ip" {
  description = "Elastic IP tĩnh của Bastion — dùng IP này để SSH"
  value       = aws_eip.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID của Bastion — dùng để quản lý trên AWS Console"
  value       = aws_instance.bastion.id
}

output "bastion_ami_used" {
  description = "AMI ID đang dùng (Amazon Linux 2023 mới nhất tại thời điểm apply)"
  value       = data.aws_ami.amazon_linux.id
}

output "ssh_command" {
  description = "Lệnh SSH vào Bastion Host"
  value       = "ssh -i ~/.ssh/tamtm-bastion ec2-user@${aws_eip.bastion.public_ip}"
}

output "ssh_to_nodes_via_bastion" {
  description = "Lệnh SSH vào Worker Node thông qua Bastion (thay NODE_PRIVATE_IP bằng IP thực)"
  value       = "ssh -i ~/.ssh/tamtm-bastion -J ec2-user@${aws_eip.bastion.public_ip} ec2-user@<NODE_PRIVATE_IP>"
}

output "setup_kubectl_on_bastion" {
  description = "Lệnh cấu hình kubectl trên Bastion sau khi SSH vào"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}
