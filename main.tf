module "infra" {
  source = "./module"

  aws_region      = var.aws_region
  regionDefault   = var.regionDefault
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  projectName     = var.projectName
  nodeGroup       = var.nodeGroup
  role            = var.role
  instanceType    = var.instanceType
  s3_bucket_name  = var.s3_bucket_name
  sonar_ami_id          = var.sonar_ami_id
  sonar_instance_type   = var.sonar_instance_type
  sonar_key_name        = var.sonar_key_name
}