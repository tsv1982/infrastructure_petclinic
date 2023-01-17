output "nat_gateway_ip" {
  value = aws_eip.eip_nat_gateway.public_ip
}

output "instance_private_ip" {
  value = aws_instance.mysql_instance.private_ip
}

output "bastion_pub_ip" {
  value = aws_eip.eip_bastion.public_ip
}
