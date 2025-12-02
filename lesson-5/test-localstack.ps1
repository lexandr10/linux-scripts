# PowerShell скрипт для тестування Terraform з LocalStack на Windows

Write-Host "🚀 Запуск тестування Terraform з LocalStack" -ForegroundColor Cyan
Write-Host ""

# Перевірка чи запущений LocalStack
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✅ LocalStack запущений" -ForegroundColor Green
} catch {
    Write-Host "❌ LocalStack не запущений!" -ForegroundColor Red
    Write-Host "Запустіть LocalStack: localstack start" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Копіювання прикладів конфігурації
Write-Host "📝 Налаштування конфігурації для LocalStack..." -ForegroundColor Cyan
Copy-Item -Path "main-localstack.tf.example" -Destination "main.tf" -Force
Copy-Item -Path "backend-local.tf.example" -Destination "backend.tf" -Force

# Ініціалізація Terraform
Write-Host "🔧 Ініціалізація Terraform..." -ForegroundColor Cyan
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Помилка ініціалізації Terraform" -ForegroundColor Red
    exit 1
}

# Валідація конфігурації
Write-Host "✅ Валідація конфігурації..." -ForegroundColor Cyan
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Помилка валідації конфігурації" -ForegroundColor Red
    exit 1
}

# Форматування коду
Write-Host "📐 Форматування коду..." -ForegroundColor Cyan
terraform fmt

# План розгортання
Write-Host "📋 Створення плану розгортання..." -ForegroundColor Cyan
terraform plan

Write-Host ""
Write-Host "✨ Тестування завершено!" -ForegroundColor Green
Write-Host ""
Write-Host "Для застосування змін виконайте: terraform apply" -ForegroundColor Yellow
Write-Host "Для видалення: terraform destroy" -ForegroundColor Yellow

