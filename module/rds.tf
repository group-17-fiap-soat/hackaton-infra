locals {
  subnet_id_map_public_only = {
    public-1 = aws_subnet.public[0].id
    public-2 = aws_subnet.public[1].id
  }
}

resource "aws_db_subnet_group" "rds_subnets" {
  name       = "hackaton-rds-subnet-public-group"
  subnet_ids = values(local.subnet_id_map_public_only)

  tags = {
    Name = "hackaton-rds-subnet-public-group"
  }
}


resource "aws_db_instance" "auth" {
  identifier             = "hackaton-auth-db"
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "hackatonAuth"
  username               = var.db_user
  password               = var.db_password
  port                   = 5432
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.sg_postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  skip_final_snapshot    = true

  tags = {
    Name = "hackaton-auth-db"
  }
}

resource "aws_db_instance" "keyframe" {
  identifier             = "hackaton-keyframe-db"
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "hackatonKeyframe"
  username               = var.db_user
  password               = var.db_password
  port                   = 5432
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.sg_postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  skip_final_snapshot    = true

  tags = {
    Name = "hackaton-keyframe-db"
  }
}
