resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids
}
resource "aws_db_instance" "main" {
  identifier        = "${var.name}-db"
  engine            = "sqlserver-ex"
  instance_class    = var.instance_class
  allocated_storage = 20
  username                    = var.db_username
  manage_master_user_password = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false
  storage_encrypted   = true
  skip_final_snapshot = true
}