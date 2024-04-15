terraform {
  backend "s3" {
    bucket = "tf-storage-backend"
    key = "ecs-example/pro/terraform.tfstate"
    region  = "ap-northeast-1"
  }
}
