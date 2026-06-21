output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs in input order."
  value = [
    for index in range(length(var.public_subnet_cidrs)) :
    aws_subnet.public[tostring(index)].id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs in input order."
  value = [
    for index in range(length(var.private_subnet_cidrs)) :
    aws_subnet.private[tostring(index)].id
  ]
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "NAT gateway ID, or null when NAT is disabled."
  value       = try(aws_nat_gateway.this[0].id, null)
}
