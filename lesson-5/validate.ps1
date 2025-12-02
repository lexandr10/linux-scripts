# Швидка перевірка синтаксису Terraform

Write-Host "🔍 Перевірка синтаксису Terraform..." -ForegroundColor Cyan
Write-Host ""

# Форматування
Write-Host "📐 Форматування коду..." -ForegroundColor Yellow
terraform fmt -recursive

# Валідація (потребує ініціалізації)
if (Test-Path ".terraform") {
    Write-Host "✅ Валідація конфігурації..." -ForegroundColor Yellow
    terraform validate
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✨ Валідація пройшла успішно!" -ForegroundColor Green
    } else {
        Write-Host "❌ Помилки валідації!" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Terraform не ініціалізований. Виконайте: terraform init" -ForegroundColor Yellow
}

