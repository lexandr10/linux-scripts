# Домашнє завдання: IaC (Terraform)

Цей проєкт містить Terraform-структуру для розгортання інфраструктури на AWS.

## Структура проєкту

```
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf              # Загальне виведення ресурсів
├── variables.tf             # Глобальні змінні
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf        # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf           # Створення ECR репозиторію
│       ├── variables.tf     # Змінні для ECR
│       └── outputs.tf       # Виведення URL репозиторію ECR
│
└── README.md                # Документація проєкту
```

## Опис модулів

### 1. Модуль s3-backend

Модуль для налаштування бекенду Terraform:
- **S3 бакет**: Зберігає стейт-файли Terraform з увімкненим версіюванням
- **DynamoDB таблиця**: Використовується для блокування стейтів під час одночасного доступу
- **Безпека**: Шифрування на рівні S3, блокування публічного доступу

### 2. Модуль vpc

Модуль для створення мережевої інфраструктури:
- **VPC**: Віртуальна приватна хмара з налаштованим DNS
- **Публічні підмережі**: 3 підмережі з доступом до Internet через Internet Gateway
- **Приватні підмережі**: 3 підмережі з доступом до Internet через NAT Gateway
- **Маршрутизація**: Автоматична налаштування Route Tables для публічних та приватних підмереж

### 3. Модуль ecr

Модуль для створення ECR репозиторію:
- **ECR репозиторій**: Для зберігання Docker-образів
- **Сканування**: Автоматичне сканування образів на вразливості при push
- **Lifecycle policy**: Автоматичне видалення старих образів (зберігає останні 10)
- **Політика доступу**: Налаштування прав доступу до репозиторію

## Передумови

1. Встановлений Terraform (версія >= 1.0)
2. Налаштовані AWS credentials (через `aws configure` або змінні оточення)
3. AWS аккаунт з відповідними правами

## Використання

### 1. Налаштування бекенду

**ВАЖЛИВО**: Перед використанням необхідно створити S3 бакет та DynamoDB таблицю вручну або через окремий Terraform проєкт, оскільки бекенд налаштовується до ініціалізації.

Альтернативно, можна використати локальний бекенд для тестування:

```hcl
# backend.tf (для тестування)
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

### 2. Ініціалізація проєкту

```bash
terraform init
```

### 3. Перевірка плану розгортання

```bash
terraform plan
```

### 4. Застосування змін

```bash
terraform apply
```

Підтвердіть виконання, ввівши `yes`.

### 5. Перегляд вихідних даних

Після успішного розгортання ви побачите:
- URL S3 бакета та DynamoDB таблиці
- ID VPC та підмереж
- URL ECR репозиторію

### 6. Видалення інфраструктури

```bash
terraform destroy
```

## Тестування без AWS

Для тестування без реального AWS можна використати:

### Варіант 1: LocalStack

1. Встановіть LocalStack:
```bash
pip install localstack
```

2. Запустіть LocalStack:
```bash
localstack start
```

3. Налаштуйте AWS endpoint у `main.tf`:
```hcl
provider "aws" {
  region = "us-east-1"
  
  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    ec2      = "http://localhost:4566"
    ecr      = "http://localhost:4566"
  }
  
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}
```

4. Використовуйте локальний бекенд:
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

### Варіант 2: Валідація синтаксису

Просто перевірте синтаксис без розгортання:

```bash
terraform fmt -check
terraform validate
```

## Налаштування змінних

Змінні можна перевизначити через файл `terraform.tfvars`:

```hcl
aws_region          = "us-west-2"
backend_bucket_name = "my-terraform-state-bucket"
backend_table_name  = "terraform-locks"
vpc_cidr_block      = "10.0.0.0/16"
vpc_name            = "lesson-5-vpc"
ecr_name            = "lesson-5-ecr"
```

## Важливі примітки

1. **S3 бакет**: Ім'я бакета має бути унікальним глобально в AWS
2. **NAT Gateway**: Створює 3 NAT Gateway (по одному на приватну підмережу), що може бути дорого. Для економії можна використати один NAT Gateway для всіх приватних підмереж
3. **ECR політика**: Поточна політика дозволяє доступ всім. Для продакшену обмежте доступ до конкретних користувачів/ролей

## Вирішення проблем

### Помилка: "Backend configuration changed"
Якщо змінюєте бекенд, виконайте:
```bash
terraform init -migrate-state
```

### Помилка: "Bucket already exists"
Змініть ім'я бакета у змінних на унікальне.

### Помилка: "Insufficient permissions"
Перевірте права доступу AWS credentials та IAM політики.

