resource "aws_elasticache_subnet_group" "redis" {
  name       = "hackaton-redis-subnet-group"
  subnet_ids = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = {
    Name = "hackaton-redis-subnet-group"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "hackaton-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.sg.id]

  tags = {
    Name = "hackaton-redis"
  }
}