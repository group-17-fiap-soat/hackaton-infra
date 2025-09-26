# ECR: keyframe Service
resource "aws_ecr_repository" "keyframe" {
  name                 = "keyframe-hackaton"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "keyframe-hackaton-ecr"
    Environment = "dev"
  }
}

resource "aws_ecr_lifecycle_policy" "keyframe_policy" {
  repository = aws_ecr_repository.keyframe.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 10 untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR: Auth Service
resource "aws_ecr_repository" "auth" {
  name                 = "auth-hackaton"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "auth-hackaton-ecr"
    Environment = "dev"
  }
}

resource "aws_ecr_lifecycle_policy" "auth_policy" {
  repository = aws_ecr_repository.auth.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 10 untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
