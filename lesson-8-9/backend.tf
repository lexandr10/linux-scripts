terraform {
  backend "s3" {
    # Ці значення потрібно буде налаштувати після створення S3 бакета
    # bucket         = "your-terraform-state-bucket"
    # key            = "lesson-8-9/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}

