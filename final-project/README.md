# Фінальний проєкт: Повна CI/CD інфраструктура на AWS

Цей проєкт реалізує повну інфраструктуру для розгортання Django-застосунку на AWS з використанням Terraform, Kubernetes, Jenkins, Argo CD та моніторингу.

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
                                                    │              │
                                                    │  ┌────────┐ │
                                                    │  │ Django │ │
                                                    │  │   App  │ │
                                                    │  └───┬────┘ │
                                                    │      │      │
                                                    │  ┌───▼────┐ │
                                                    │  │  RDS   │ │
                                                    │  └────────┘ │
                                                    │              │
                                                    │  ┌─────────┐│
                                                    │  │Prometheus││
                                                    │  │ Grafana ││
                                                    │  └─────────┘│
                                                    └──────────────┘
```

## Компоненти

- **VPC** - Віртуальна приватна мережа з публічними та приватними підмережами
- **EKS** - Kubernetes кластер з EBS CSI driver
- **ECR** - Container registry для Docker образів
- **RDS** - База даних (PostgreSQL/MySQL або Aurora)
- **Jenkins** - CI/CD сервер з Kaniko для збірки образів
- **Argo CD** - GitOps інструмент для автоматичного розгортання
- **Prometheus** - Система моніторингу та збору метрик
- **Grafana** - Візуалізація метрик та дашборди

## Структура проєкту

```
final-project/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів
├── outputs.tf               # Загальні виводи ресурсів
├── variables.tf             # Змінні Terraform
├── terraform.tfvars.example # Приклад конфігурації
│
├── modules/
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   ├── ecr/                 # Модуль для ECR
│   ├── eks/                 # Модуль для EKS (з EBS CSI driver)
│   ├── rds/                 # Модуль для RDS/Aurora
│   ├── jenkins/             # Модуль для Jenkins (Helm)
│   ├── argo_cd/             # Модуль для Argo CD (Helm)
│   │   └── charts/          # Helm chart для Argo CD Applications
│   └── monitoring/          # Модуль для Prometheus + Grafana
│
├── charts/
│   └── django-app/         # Helm chart для Django застосунку
│
└── Django/                  # Django застосунок
    ├── app/
    ├── Dockerfile
    ├── Jenkinsfile
    └── docker-compose.yaml
```

## Передумови

1. AWS CLI налаштований з коректними credentials
2. Terraform >= 1.0
3. kubectl встановлений
4. Helm 3 встановлений
5. Git репозиторій для Helm charts

## Крок 1: Підготовка середовища

### 1.1. Налаштування Terraform Backend

1. Створіть файл `terraform.tfvars` на основі `terraform.tfvars.example`:

```hcl
aws_region          = "us-east-1"
name_prefix         = "final-project"
s3_bucket_name      = "your-terraform-state-bucket-name"
dynamodb_table_name = "terraform-state-lock"
git_repository_url  = "https://github.com/your-username/your-repo.git"
rds_master_password  = "SecurePassword123!"
```

2. Спочатку створіть S3 бакет та DynamoDB:

```bash
cd final-project
terraform init
terraform apply -target=module.s3_backend
```

3. Оновіть `backend.tf` з реальними значеннями:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "final-project/terraform.tfstate"
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

## Крок 2: Розгортання інфраструктури

### 2.1. Застосування Terraform

```bash
terraform plan
terraform apply
```

Це створить:
- VPC з підмережами
- ECR репозиторій
- EKS кластер з EBS CSI driver
- RDS базу даних
- Jenkins (через Helm)
- Argo CD (через Helm)
- Prometheus + Grafana (через Helm)

### 2.2. Налаштування kubectl

```bash
aws eks update-kubeconfig --region <your-region> --name final-project-cluster
kubectl get nodes
```

### 2.3. Перевірка стану ресурсів

```bash
# Jenkins
kubectl get all -n jenkins

# Argo CD
kubectl get all -n argocd

# Monitoring
kubectl get all -n monitoring
```

## Крок 3: Перевірка доступності

### 3.1. Jenkins

1. Отримайте URL та пароль:

```bash
terraform output jenkins_url
terraform output jenkins_admin_password
```

2. Або використайте port-forward:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Відкрийте http://localhost:8080 в браузері.

### 3.2. Argo CD

1. Отримайте URL та пароль:

```bash
terraform output argocd_url
terraform output argocd_admin_password
```

2. Або використайте port-forward:

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Відкрийте https://localhost:8081 в браузері.

### 3.3. Grafana

1. Отримайте URL:

```bash
terraform output grafana_url
```

2. Або використайте port-forward:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Відкрийте http://localhost:3000 в браузері.
- Username: `admin`
- Password: `admin` (змініть після першого входу)

## Крок 4: Налаштування Jenkins

### 4.1. Створення Secret для ECR

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
   - New Item → Pipeline
   - Назва: `django-app-cicd`
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: URL вашого Git репозиторію
   - Branch: `*/main`
   - Script Path: `Django/Jenkinsfile`

2. Додайте Environment Variables:
   - Manage Jenkins → Configure System → Global properties
   - Environment variables:
     - `ECR_REGISTRY`: (AWS account ID).dkr.ecr.us-east-1.amazonaws.com
     - `ECR_REPOSITORY`: django-app
     - `GIT_REPO_URL`: https://github.com/your-username/your-repo.git

## Крок 5: Налаштування Argo CD

### 5.1. Перевірка Application

```bash
kubectl get applications -n argocd
kubectl describe application django-app -n argocd
```

### 5.2. Перевірка в Argo CD UI

1. Відкрийте Argo CD UI
2. Перевірте Application `django-app`
3. Статус синхронізації має бути "Synced"

## Крок 6: Моніторинг та перевірка метрик

### 6.1. Grafana

1. Відкрийте Grafana UI
2. Перевірте, що Prometheus datasource налаштований
3. Створіть дашборди для моніторингу:
   - CPU використання
   - Memory використання
   - Кількість подів
   - Database connections

### 6.2. Prometheus

```bash
# Перевірка Prometheus
kubectl get pods -n monitoring | grep prometheus

# Перевірка метрик
kubectl port-forward svc/prometheus-operator-kube-p-prometheus 9090:9090 -n monitoring
```

Відкрийте http://localhost:9090 в браузері.

### 6.3. Перевірка HPA

```bash
kubectl get hpa
kubectl describe hpa django-app
```

## Крок 7: Перевірка CI/CD Pipeline

### 7.1. Запуск Jenkins Pipeline

1. В Jenkins UI:
   - Виберіть job `django-app-cicd`
   - Натисніть "Build Now"

2. Pipeline виконає:
   - Checkout коду з Git
   - Збірку Docker образу через Kaniko
   - Push образу до ECR
   - Оновлення тегу в `charts/django-app/values.yaml`
   - Push змін до Git

### 7.2. Перевірка оновлення в Argo CD

1. Після успішного виконання Jenkins pipeline:
   - Argo CD автоматично виявить зміни в Git
   - Застосує оновлення до кластера

2. Перевірте статус:

```bash
kubectl get pods -l app.kubernetes.io/name=django-app
kubectl get services
kubectl get hpa
```

## Оцінювання проєкту

### Критерії оцінювання (0-100 балів):

1. **Створено середовище з коректною архітектурою (20 балів)**
   - ✅ VPC з публічними та приватними підмережами
   - ✅ EKS кластер з EBS CSI driver
   - ✅ ECR репозиторій
   - ✅ RDS база даних
   - ✅ Jenkins, Argo CD, Prometheus, Grafana

2. **Налаштовано безпеку через VPC, IAM, Security Groups (20 балів)**
   - ✅ VPC з правильними маршрутами
   - ✅ Security Groups для RDS та EKS
   - ✅ IAM ролі для EKS та EBS CSI driver
   - ✅ Приватні підмережі для БД

3. **Розгорнуто застосунок в AWS з CI/CD (30 балів)**
   - ✅ Jenkins pipeline з Kaniko
   - ✅ Автоматичне оновлення Helm chart
   - ✅ Argo CD автоматична синхронізація
   - ✅ HPA для автомасштабування

4. **Налаштовано моніторинг та автомасштабування (20 балів)**
   - ✅ Prometheus для збору метрик
   - ✅ Grafana для візуалізації
   - ✅ HPA для автомасштабування подів
   - ✅ Метрики CPU та Memory

5. **Коректне оформлення та зрозумілість документації (10 балів)**
   - ✅ README.md з повною документацією
   - ✅ Коментарі в коді
   - ✅ Структура проєкту

## Troubleshooting

### Jenkins не може підключитися до кластера

```bash
kubectl get clusterrolebinding | grep jenkins
kubectl get serviceaccount -n jenkins
```

### Kaniko не може push до ECR

```bash
kubectl get secret docker-registry-secret -n jenkins
aws ecr describe-repositories --repository-names django-app
```

### Argo CD не синхронізує

```bash
kubectl describe application django-app -n argocd
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Prometheus не збирає метрики

```bash
kubectl get pods -n monitoring | grep prometheus
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
```

### HPA не працює

```bash
kubectl describe hpa django-app
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/default/pods"
```

## Важливі команди

```bash
# Отримати всі outputs
terraform output

# Оновити kubeconfig
aws eks update-kubeconfig --region us-east-1 --name final-project-cluster

# Перевірити всі компоненти
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get all -l app.kubernetes.io/name=django-app

# Port-forward для доступу
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl port-forward svc/argocd-server 8081:443 -n argocd
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## Видалення ресурсів

```bash
terraform destroy
```

**Увага**: Переконайтеся, що видалили всі ресурси перед видаленням S3 бакета для state.

## Додаткові ресурси

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Grafana Documentation](https://grafana.com/docs/)

