resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "stamq"
  subnet_ids = [
    aws_subnet.private-db-1.id,
    aws_subnet.private-db-2.id,
    aws_subnet.private-db-3.id,
  ]
}

resource "aws_db_instance" "rds" {
  identifier             = "stamq-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  storage_type           = "gp2"
  allocated_storage      = 10
  max_allocated_storage  = 100
  username               = var.username
  password               = var.password
  multi_az               = true
  skip_final_snapshot    = true
  backup_window          = "21:00-21:30"
  maintenance_window     = "Sun:22:00-Sun:22:30"
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  lifecycle {
    ignore_changes = [password]
  }

  tags = {
    Name    = "stamq-db"
  }
}
