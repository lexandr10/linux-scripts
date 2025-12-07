# Домашнє завдання до теми «Вивчення Argo CD + CD»

Цей проєкт реалізує повний CI/CD процес з використанням Jenkins, Terraform, ECR, Helm та Argo CD для автоматичного розгортання Django-застосунку на Kubernetes.

## Архітектура

```
┌─────────────┐     ┌──────────┐     ┌─────────┐     ┌──────────┐
│   Git Repo  │────▶│ Jenkins  │────▶│   ECR   │────▶│ Argo CD  │
│  (Helm)     │     │ Pipeline │     │ (Images)│     │          │
└─────────────┘     └──────────┘     └─────────┘     └────┬─────┘
                                                           │
                                                           ▼
                                                    ┌──────────────┐
                                                    │   EKS        │
                                                    │   Cluster    │
                                                    └──────────────┘
```

## Структура проєкту

```
lesson-8-9/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів
├── outputs.tf               # Загальні виводи ресурсів
├── variables.tf             # Змінні Terraform
├── Jenkinsfile              # CI/CD pipeline для Jenkins
├── Dockerfile.example       # Приклад Dockerfile для Django
│
├── modules/
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   ├── ecr/                 # Модуль для ECR
│   ├── eks/                 # Модуль для EKS (з EBS CSI driver)
│   ├── jenkins/             # Модуль для Jenkins (Helm)
│   └── argo_cd/             # Модуль для Argo CD (Helm)
│       └── charts/         # Helm chart для Argo CD Applications
│
└── charts/
    └── django-app/         # Helm chart для Django застосунку
```

## Передумови

1. AWS CLI налаштований з коректними credentials
2. Terraform >= 1.0
3. kubectl встановлений
4. Helm 3 встановлений
5. Git репозиторій для Helm charts

## Крок 1: Налаштування Terraform Backend

1. Створіть файл `terraform.tfvars`:

```hcl
aws_region          = "us-east-1"
name_prefix         = "lesson-8-9"
s3_bucket_name      = "your-unique-terraform-state-bucket-name"
dynamodb_table_name = "terraform-state-lock"
ecr_repository_name = "django-app"
cluster_name        = "lesson-8-9-cluster"
git_repository_url  = "https://github.com/your-username/your-repo.git"
git_repository_path = "charts/django-app"
target_revision     = "main"
```

2. Спочатку створіть S3 бакет та DynamoDB:

```bash
cd lesson-8-9
terraform init
terraform apply -target=module.s3_backend
```

3. Оновіть `backend.tf` з реальними значеннями:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket-name"
    key            = "lesson-8-9/terraform.tfstate"
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

1. Застосуйте Terraform:

```bash
terraform plan
terraform apply
```

Це створить:
- VPC з підмережами
- ECR репозиторій
- EKS кластер з EBS CSI driver
- Jenkins (через Helm)
- Argo CD (через Helm)

2. Налаштуйте kubectl:

```bash
aws eks update-kubeconfig --region <your-region> --name lesson-8-9-cluster
kubectl get nodes
```

## Крок 3: Отримання доступу до Jenkins

1. Отримайте URL Jenkins:

```bash
terraform output jenkins_url
```

2. Отримайте пароль адміністратора:

```bash
terraform output jenkins_admin_password
# Або виконайте команду напряму:
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```

3. Відкрийте Jenkins в браузері та увійдіть з:
   - Username: `admin`
   - Password: (з команди вище)

## Крок 4: Налаштування Jenkins

### 4.1. Створення Secret для ECR

1. Отримайте ECR URL:

```bash
terraform output ecr_repository_url
```

2. Створіть Kubernetes Secret для доступу до ECR:

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | kubectl create secret docker-registry docker-registry-secret \
  --docker-server=$ECR_URL \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=jenkins \
  --dry-run=client -o yaml | kubectl apply -f -
```

### 4.2. Налаштування Jenkins Job

1. В Jenkins UI:
   - Натисніть "New Item"
   - Виберіть "Pipeline"
   - Назва: `django-app-cicd`

2. В конфігурації Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: URL вашого Git репозиторію
   - Credentials: (додайте Git credentials якщо потрібно)
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

3. Додайте Environment Variables в Jenkins:
   - Manage Jenkins → Configure System → Global properties → Environment variables
   - Додайте:
     - `ECR_REGISTRY`: (AWS account ID).dkr.ecr.us-east-1.amazonaws.com
     - `ECR_REPOSITORY`: django-app
     - `GIT_REPO_URL`: https://github.com/your-username/your-repo.git
     - `GIT_CREDENTIALS_ID`: (якщо потрібно)

## Крок 5: Налаштування Argo CD

### 5.1. Отримання доступу

1. Отримайте URL Argo CD:

```bash
terraform output argocd_url
```

2. Отримайте пароль адміністратора:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

3. Відкрийте Argo CD в браузері та увійдіть:
   - Username: `admin`
   - Password: (з команди вище)

### 5.2. Перевірка Application

1. Перевірте, що Application створено:

```bash
kubectl get applications -n argocd
kubectl describe application django-app -n argocd
```

2. В Argo CD UI ви побачите:
   - Application `django-app`
   - Статус синхронізації
   - Ресурси в кластері

## Крок 6: Перевірка CI/CD Pipeline

### 6.1. Запуск Jenkins Pipeline

1. В Jenkins UI:
   - Виберіть job `django-app-cicd`
   - Натисніть "Build Now"

2. Pipeline виконає:
   - Checkout коду з Git
   - Збірку Docker образу через Kaniko
   - Push образу до ECR
   - Оновлення тегу в `charts/django-app/values.yaml`
   - Push змін до Git

### 6.2. Перевірка оновлення в Argo CD

1. Після успішного виконання Jenkins pipeline:
   - Argo CD автоматично виявить зміни в Git
   - Застосує оновлення до кластера

2. Перевірте статус:

```bash
# Перевірка подів
kubectl get pods -l app.kubernetes.io/name=django-app

# Перевірка сервісів
kubectl get services

# Перевірка HPA
kubectl get hpa
```

## Крок 7: Перевірка результату

### 7.1. Перевірка Jenkins Job

```bash
# Переглянути логи Jenkins
kubectl logs -n jenkins -l app.kubernetes.io/name=jenkins

# Перевірити статус pipeline
# (через Jenkins UI або API)
```

### 7.2. Перевірка в Argo CD

1. В Argo CD UI:
   - Відкрийте Application `django-app`
   - Перевірте статус синхронізації
   - Перегляньте ресурси

2. Через kubectl:

```bash
# Перевірка Application
kubectl get application django-app -n argocd -o yaml

# Перевірка синхронізації
kubectl get application django-app -n argocd -o jsonpath='{.status.sync.status}'
```

## Troubleshooting

### Jenkins не може підключитися до кластера

```bash
# Перевірте RBAC
kubectl get clusterrolebinding | grep jenkins
kubectl get serviceaccount -n jenkins
```

### Kaniko не може push до ECR

```bash
# Перевірте secret
kubectl get secret docker-registry-secret -n jenkins

# Перевірте права доступу
aws ecr describe-repositories --repository-names django-app
```

### Argo CD не синхронізує

```bash
# Перевірте Application
kubectl describe application django-app -n argocd

# Перевірте Repository
kubectl get secrets -n argocd | grep repo

# Перевірте логи Argo CD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Помилки з Helm chart

```bash
# Валідація Helm chart
cd charts/django-app
helm lint .
helm template . --debug
```

## Важливі команди

```bash
# Отримати всі outputs
terraform output

# Оновити kubeconfig
aws eks update-kubeconfig --region us-east-1 --name lesson-8-9-cluster

# Перевірити Jenkins
kubectl get svc -n jenkins
kubectl get pods -n jenkins

# Перевірити Argo CD
kubectl get svc -n argocd
kubectl get pods -n argocd

# Перевірити застосунок
kubectl get all -l app.kubernetes.io/name=django-app
```

## Видалення ресурсів

```bash
# Видалення через Terraform
terraform destroy

# Або видалення окремих компонентів
helm uninstall jenkins -n jenkins
helm uninstall argocd -n argocd
```

## Додаткові ресурси

- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Kaniko Documentation](https://github.com/GoogleContainerTools/kaniko)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)

