resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}
