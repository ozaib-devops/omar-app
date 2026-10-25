output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "used by rds and lambda"
  value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}