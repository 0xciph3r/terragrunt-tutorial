output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the created VPC"
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  description = "The IDs of the created public subnets"
}
output "app_subnet_ids" {
  value = aws_subnet.app[*].id
  description = "The IDs of the created application subnets"
}
output "data_subnet_ids" {
  value = aws_subnet.data[*].id
  description = "The IDs of the created data subnets"   
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
  description = "The CIDR block of the created VPC"
}