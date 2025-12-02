# ВАЖЛИВО: Перед використанням змініть ім'я бакета на унікальне!
# S3 бакет та DynamoDB таблиця повинні бути створені заздалегідь
# або використайте локальний бекенд для тестування (див. backend-local.tf.example)
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-name" # ЗМІНІТЬ на унікальне ім'я!
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
