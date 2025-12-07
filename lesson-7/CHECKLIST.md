# Чеклист перевірки проєкту

## Швидка перевірка

### 1. Запустіть скрипт валідації:
```powershell
.\validate.ps1
```

### 2. Перевірка структури файлів:
```powershell
# Перевірка основних файлів
Test-Path main.tf, backend.tf, outputs.tf, variables.tf

# Перевірка модулів
Get-ChildItem modules -Directory | Select-Object Name

# Перевірка Helm chart
Get-ChildItem charts\django-app -Recurse | Select-Object FullName
```

### 3. Валідація Terraform (після налаштування backend):
```powershell
terraform init
terraform validate
terraform fmt -check
```

### 4. Валідація Helm chart (якщо встановлений Helm):
```powershell
cd charts\django-app
helm lint .
helm template . --debug
```

### 5. Перевірка ключових компонентів:

#### Terraform модулі:
- [x] s3-backend (s3.tf, dynamodb.tf, variables.tf, outputs.tf)
- [x] vpc (vpc.tf, routes.tf, variables.tf, outputs.tf)
- [x] ecr (ecr.tf, variables.tf, outputs.tf)
- [x] eks (eks.tf, variables.tf, outputs.tf)

#### Helm Chart templates:
- [x] deployment.yaml (з envFrom для ConfigMap)
- [x] service.yaml (тип LoadBalancer)
- [x] hpa.yaml (min: 2, max: 6, CPU/Memory > 70%)
- [x] configmap.yaml (для змінних середовища)
- [x] ingress.yaml (з підтримкою TLS та cert-manager)
- [x] _helpers.tpl (helper функції)

#### Values.yaml:
- [x] ingress.enabled (можливість вмикання/вимикання)
- [x] ingress.className (nginx)
- [x] ingress.host (домен)
- [x] ingress.tls (HTTPS)
- [x] ingress.annotations (cert-manager.io/cluster-issuer)
- [x] configMap.env (змінні середовища)
- [x] autoscaling (minReplicas: 2, maxReplicas: 6)

### 6. Перевірка Ingress конфігурації:

Відкрийте `charts/django-app/templates/ingress.yaml` та переконайтеся:
- [x] Умовне створення через `{{- if .Values.ingress.enabled -}}`
- [x] Підтримка `ingressClassName`
- [x] Підтримка TLS з `secretName`
- [x] Анотації з `cert-manager.io/cluster-issuer`
- [x] Правильний path та pathType

### 7. Перевірка Deployment:

Відкрийте `charts/django-app/templates/deployment.yaml` та переконайтеся:
- [x] Використання образу з ECR
- [x] `envFrom` з `configMapRef`
- [x] Налаштовані liveness та readiness проби
- [x] Ресурси (limits та requests)

### 8. Перевірка HPA:

Відкрийте `charts/django-app/templates/hpa.yaml` та переконайтеся:
- [x] Умовне створення через `{{- if .Values.autoscaling.enabled -}}`
- [x] minReplicas: 2
- [x] maxReplicas: 6
- [x] CPU та Memory метрики з порогом 70%

## Команди для тестування після розгортання:

```powershell
# Перевірка підключення до кластера
kubectl get nodes

# Перевірка подів
kubectl get pods -l app.kubernetes.io/name=django-app

# Перевірка сервісів
kubectl get services

# Перевірка HPA
kubectl get hpa

# Перевірка Ingress (якщо ввімкнено)
kubectl get ingress

# Перевірка ConfigMap
kubectl get configmap
kubectl describe configmap <configmap-name>

# Перевірка логів
kubectl logs -l app.kubernetes.io/name=django-app

# Перевірка сертифікатів (якщо використовується cert-manager)
kubectl get certificate
kubectl describe certificate <certificate-name>
```

## Типові проблеми та рішення:

1. **Terraform init не працює без backend:**
   - Спочатку створіть S3 бакет вручну або закоментуйте backend.tf

2. **Helm lint не знаходить помилок:**
   - Перевірте синтаксис YAML вручну
   - Використайте `helm template . --debug` для перевірки

3. **Ingress не створюється:**
   - Перевірте `ingress.enabled: true` в values.yaml
   - Переконайтеся, що ingress controller встановлений

4. **Cert-manager не працює:**
   - Перевірте, що cert-manager встановлений
   - Перевірте ClusterIssuer: `kubectl get clusterissuer`

