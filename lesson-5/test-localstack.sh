#!/bin/bash

# Скрипт для тестування Terraform з LocalStack

echo "🚀 Запуск тестування Terraform з LocalStack"
echo ""

# Перевірка чи запущений LocalStack
if ! curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "❌ LocalStack не запущений!"
    echo "Запустіть LocalStack: localstack start"
    exit 1
fi

echo "✅ LocalStack запущений"
echo ""

# Копіювання прикладів конфігурації
echo "📝 Налаштування конфігурації для LocalStack..."
cp main-localstack.tf.example main.tf
cp backend-local.tf.example backend.tf

# Ініціалізація Terraform
echo "🔧 Ініціалізація Terraform..."
terraform init

# Валідація конфігурації
echo "✅ Валідація конфігурації..."
terraform validate

# Форматування коду
echo "📐 Форматування коду..."
terraform fmt

# План розгортання
echo "📋 Створення плану розгортання..."
terraform plan

echo ""
echo "✨ Тестування завершено!"
echo ""
echo "Для застосування змін виконайте: terraform apply"
echo "Для видалення: terraform destroy"

