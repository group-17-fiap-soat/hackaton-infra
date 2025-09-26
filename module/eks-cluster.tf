module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.3.0"

  cluster_name    = var.projectName
  cluster_version = "1.32"
  vpc_id          = aws_vpc.hackaton.id

  subnet_ids = concat(
    aws_subnet.public[*].id,
    aws_subnet.private[*].id
  )

  cluster_endpoint_public_access = true

  cluster_enabled_log_types = [
    "api", "audit", "authenticator"
  ]

  eks_managed_node_groups = {
    (var.nodeGroup) = {
      desired_size   = 2
      min_size       = 1
      max_size       = 2
      instance_types = [var.instanceType]
      key_name       = "devkeypair"
      iam_role_arn   = var.role
    }
  }

  access_entries = { 
    admin = {
      principal_arn        = "arn:aws:iam::361598269712:user/root"
      type                 = "STANDARD"
      policy_associations  = []
      username             = "admin"
    }
  }
}