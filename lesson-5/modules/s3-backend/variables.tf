variable "bucket_name" {
  description = "Ім'я S3 бакета для стейт-файлів"
  type        = string
}

variable "table_name" {
  description = "Ім'я DynamoDB таблиці для блокування"
  type        = string
}

variable "region" {
  description = "AWS регіон"
  type        = string
}

