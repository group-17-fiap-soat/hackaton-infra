#####################################
#        ECR Repository Outputs     #
#####################################
output "ecr_repository_name" {
  value = aws_ecr_repository.keyframe.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.keyframe.repository_url
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.keyframe.arn
}
#####################################
#         Networking Outputs        #
#####################################
output "vpc_id" {
  value       = aws_vpc.hackaton.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of private subnet IDs"
}

output "security_group_id" {
  value       = aws_security_group.sg.id
  description = "Security group ID used by cluster"
}

#####################################
#               EKS                 #
#####################################
# outputs.tf
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "sonar_endpoint" {
  description = "Endpoint do Sonar"
  value       = aws_instance.sonar.public_ip
}

data "aws_msk_bootstrap_brokers" "bb" {
  cluster_arn = aws_msk_cluster.kafka.arn
}

output "kafka_bootstrap_brokers_plaintext" {
  value = data.aws_msk_bootstrap_brokers.bb.bootstrap_brokers
}

