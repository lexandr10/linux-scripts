# Домашнє завдання до теми «Вивчення Helm»

Цей проєкт містить інфраструктуру для розгортання Django-застосунку на Kubernetes кластері в AWS з використанням Terraform та Helm.

## Структура проєкту

```
lesson-7/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
├── variables.tf             # Змінні для Terraform
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   ├── ecr/                 # Модуль для ECR
│   └── eks/                 # Модуль для Kubernetes кластера
│
└── charts/
    └── django-app/
        ├── templates/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── configmap.yaml
        │   ├── hpa.yaml
        │   └── ingress.yaml
        ├── Chart.yaml
        └── values.yaml
```

## Передумови

1. AWS CLI налаштований з коректними credentials
2. Terraform >= 1.0 встановлений
3. kubectl встановлений
4. Helm 3 встановлений
5. Docker встановлений (для побудови та завантаження образу)

## Крок 1: Налаштування Terraform Backend

Перед першим запуском Terraform потрібно створити S3 бакет та DynamoDB таблицю для зберігання state.

1. Створіть файл `terraform.tfvars`:

```hcl
aws_region          = "us-east-1"
name_prefix         = "lesson-7"
s3_bucket_name      = "your-unique-terraform-state-bucket-name"
dynamodb_table_name = "terraform-state-lock"
ecr_repository_name = "django-app"
cluster_name        = "lesson-7-cluster"
```

2. Спочатку створіть S3 бакет та DynamoDB вручну або виконайте:

```bash
cd lesson-7
terraform init
terraform apply -target=module.s3_backend
```

3. Після створення S3 бакета, оновіть `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket-name"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

4. Повторно ініціалізуйте Terraform:

```bash
terraform init -migrate-state
```

## Крок 2: Створення інфраструктури

1. Ініціалізуйте Terraform (якщо ще не зробили):

```bash
terraform init
```

2. Перевірте план:

```bash
terraform plan
```

3. Застосуйте зміни:

```bash
terraform apply
```

Це створить:
- VPC з публічними та приватними підмережами
- ECR репозиторій для Docker образів
- EKS кластер з node group

4. Налаштуйте kubectl:

```bash
aws eks update-kubeconfig --region <your-region> --name lesson-7-cluster
```

Перевірте підключення:

```bash
kubectl get nodes
```

## Крок 3: Завантаження Docker образу до ECR

1. Отримайте URL репозиторію ECR:

```bash
terraform output ecr_repository_url
```

2. Авторизуйтеся в ECR:

```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <ecr-repository-url>
```

3. Побудуйте Docker образ (якщо у вас є Dockerfile):

```bash
docker build -t django-app:latest .
```

4. Тегуйте образ:

```bash
docker tag django-app:latest <ecr-repository-url>:latest
```

5. Завантажте образ:

```bash
docker push <ecr-repository-url>:latest
```

## Крок 4: Встановлення cert-manager (опціонально, для Ingress з TLS)

Якщо плануєте використовувати Ingress з TLS:

```bash
# Додайте Helm репозиторій cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Встановіть cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Створіть ClusterIssuer для Let's Encrypt
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

## Крок 5: Встановлення NGINX Ingress Controller (якщо використовуєте Ingress)

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

## Крок 6: Налаштування Helm Chart

1. Оновіть `charts/django-app/values.yaml`:

```yaml
image:
  repository: "<ecr-repository-url>"  # URL з ECR
  tag: "latest"

ingress:
  enabled: true
  className: "nginx"
  host: "yourdomain.com"  # Ваш домен
  path: "/"
  pathType: Prefix
  tls: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"

configMap:
  env:
    DJANGO_SETTINGS_MODULE: "myproject.settings"
    PYTHONUNBUFFERED: "1"
    DEBUG: "False"
    SECRET_KEY: "your-secret-key"
    DATABASE_URL: "postgresql://user:pass@host:5432/dbname"
    ALLOWED_HOSTS: "yourdomain.com,*.yourdomain.com"
```

2. Розгорніть застосунок через Helm:

```bash
cd charts/django-app
helm install django-app . -f values.yaml
```

Або з каталогу lesson-7:

```bash
helm install django-app ./charts/django-app -f ./charts/django-app/values.yaml
```

3. Перевірте статус:

```bash
kubectl get pods
kubectl get services
kubectl get ingress
kubectl get hpa
```

## Крок 7: Перевірка роботи

1. Отримайте LoadBalancer URL:

```bash
kubectl get service django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

2. Якщо використовуєте Ingress, перевірте:

```bash
kubectl get ingress
```

3. Перевірте HPA:

```bash
kubectl get hpa
```

4. Для тестування навантаження (опціонально):

```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# В контейнері:
while true; do wget -q -O- http://django-app:8000; done
```

## Оновлення застосунку

1. Оновіть образ в ECR:

```bash
docker build -t django-app:new-tag .
docker tag django-app:new-tag <ecr-repository-url>:new-tag
docker push <ecr-repository-url>:new-tag
```

2. Оновіть Helm release:

```bash
helm upgrade django-app ./charts/django-app --set image.tag=new-tag
```

## Видалення ресурсів

1. Видаліть Helm release:

```bash
helm uninstall django-app
```

2. Видаліть інфраструктуру:

```bash
terraform destroy
```

**Увага**: Переконайтеся, що видалили всі ресурси перед видаленням S3 бакета для state.

## Компоненти Helm Chart

### Deployment
- Використовує образ з ECR
- Підключає ConfigMap через `envFrom`
- Налаштовані liveness та readiness проби
- Ресурси обмежені через limits та requests

### Service
- Тип: LoadBalancer (для публічного доступу)
- Порт: 8000 (налаштовується в values.yaml)

### HPA (Horizontal Pod Autoscaler)
- Мінімальна кількість подів: 2
- Максимальна кількість подів: 6
- Масштабування при CPU > 70% або Memory > 70%

### ConfigMap
- Зберігає змінні середовища
- Підключається до Deployment через `envFrom`

### Ingress (опціонально)
- Підтримка TLS через cert-manager
- Налаштування через values.yaml
- Підтримка різних ingressClassName

## Troubleshooting

1. **Помилка підключення до кластера:**
   ```bash
   aws eks update-kubeconfig --region <region> --name lesson-7-cluster
   ```

2. **Поди не стартують:**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

3. **Проблеми з HPA:**
   ```bash
   kubectl describe hpa django-app
   ```

4. **Проблеми з Ingress:**
   ```bash
   kubectl describe ingress django-app
   kubectl get certificate
   ```

## Додаткові ресурси

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Helm Documentation](https://helm.sh/docs/)
- [cert-manager Documentation](https://cert-manager.io/docs/)

