## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# VPC module -  Creates a private-only network for the Lambda API and RDS SQL Server
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.name}-private_subnet_a"
  }
}
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.name}-private_subnet-b"
  }
}

## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Security groups & Rules
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#Lambda SG outbound to DB and Secrets Manager endpoint,function URL to be invoked

resource "aws_security_group" "lambda" {
  name        = "${var.name}-lambda-sg"
  description = "Lambda function"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.name}-lambda-sg"
  }
}

# DB SG inbound SQL Server from Lambda o

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "RDS SQL Server"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.name}-db-sg"
  }
}

# Endpoint SG inbound so Lambda can fetch the DB password from Secrets Manager

resource "aws_security_group" "endpoint" {
  name        = "${var.name}-endpoint-sg"
  description = "Secrets Manager VPC endpoint"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.name}-endpoint-sg"
  }
}

# Rule for Lambda to the DB
resource "aws_vpc_security_group_egress_rule" "lambda_to_db" {
  security_group_id            = aws_security_group.lambda.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 1433
  to_port                      = 1433
  description                  = "allows lambda to connect to rds"
}

# Rule for lambda to accept request from DB
resource "aws_vpc_security_group_ingress_rule" "db_from_lambda" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 1433
  to_port                      = 1433
  description                  = "allows Lambda to connect to the DB"
}

# Rule: Lambda to make requst to secrets manager
resource "aws_vpc_security_group_egress_rule" "lambda_to_endpoint" {
  security_group_id            = aws_security_group.lambda.id
  referenced_security_group_id = aws_security_group.endpoint.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "HTTPS to secrets Manager endpoint"
}

# Rule: endpoint accepts requests from Lambda 
resource "aws_vpc_security_group_ingress_rule" "endpoint_from_lambda" {
  security_group_id            = aws_security_group.endpoint.id
  referenced_security_group_id = aws_security_group.lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "HTTPS from Lambda"
}
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Secrets Manager VPC endpoint
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# access to secrets manager, so Lambda can fetch the DB password without internet access

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.name}-secretsmanager-endpoint"
  }
}