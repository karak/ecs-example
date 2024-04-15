resource "awscc_ecr_repository" "subcntr_frontend" {
  repository_name = "subcntr-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration = {
    scan_on_push = false
  }
  encryption_configuration = {
    encryption_type = "KMS"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "awscc_ecr_repository" "subcntr_backend" {
  repository_name = "subcntr-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration = {
    scan_on_push = false
  }
  encryption_configuration = {
    encryption_type = "KMS"
  }
  lifecycle {
    prevent_destroy = true
  }
}
