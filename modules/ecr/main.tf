resource "aws_ecr_repository" "subcntr_frontend" {
  name = "subcntr-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "subcntr_backend" {
  name = "subcntr-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
  lifecycle {
    prevent_destroy = true
  }
}
