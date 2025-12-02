# Інструкція з тестування через LocalStack

## Встановлення LocalStack

### Windows (через Docker)

1. Встановіть Docker Desktop
2. Запустіть LocalStack:
```powershell
docker run --rm -it -p 4566:4566 -p 4571:4571 localstack/localstack
```

### Windows (через pip)

```powershell
pip install localstack
localstack start
```

## Налаштування Terraform для LocalStack

1. Скопіюйте приклади конфігурації:
```powershell
Copy-Item main-localstack.tf.example main.tf
Copy-Item backend-local.tf.example backend.tf
```

2. Або запустіть скрипт:
```powershell
.\test-localstack.ps1
```

## Використання

1. Переконайтеся, що LocalStack запущений на `http://localhost:4566`

2. Ініціалізуйте Terraform:
```powershell
terraform init
```

3. Перевірте конфігурацію:
```powershell
terraform validate
terraform fmt
```

4. Створіть план:
```powershell
terraform plan
```

5. Застосуйте зміни:
```powershell
terraform apply
```

## Перевірка створених ресурсів

### S3
```powershell
aws --endpoint-url=http://localhost:4566 s3 ls
```

### DynamoDB
```powershell
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### VPC
```powershell
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
```

### ECR
```powershell
aws --endpoint-url=http://localhost:4566 ecr describe-repositories
```

## Повернення до реального AWS

Щоб повернутися до реального AWS:

1. Відновіть оригінальні файли:
```powershell
git checkout main.tf backend.tf
```

2. Або створіть їх заново з оригінальних прикладів

