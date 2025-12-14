# Домашнє завдання: Створення гнучкого Terraform-модуля для баз даних

Цей проєкт містить універсальний Terraform модуль для створення RDS баз даних (PostgreSQL/MySQL) або Aurora кластерів з автоматичним налаштуванням всіх необхідних ресурсів.

## Структура проєкту

```
lesson-rds/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
├── variables.tf             # Змінні Terraform
├── terraform.tfvars.example # Приклад конфігурації
│
└── modules/
    ├── s3-backend/          # Модуль для S3 та DynamoDB
    ├── vpc/                 # Модуль для VPC
    └── rds/                 # Модуль для RDS/Aurora
        ├── rds.tf           # Створення RDS instance
        ├── aurora.tf        # Створення Aurora cluster
        ├── shared.tf        # Спільні ресурси (subnet group, security group, parameter group)
        ├── variables.tf     # Змінні модуля
        └── outputs.tf        # Виводи модуля
```

## Функціонал модуля

Модуль `rds` автоматично створює:

- **DB Subnet Group** - для розміщення БД в приватних підмережах
- **Security Group** - з правилами доступу з VPC
- **Parameter Group** - з базовими параметрами (max_connections, log_statement, work_mem)

Залежно від значення `use_aurora`:
- `use_aurora = false` → створюється звичайна `aws_db_instance`
- `use_aurora = true` → створюється `aws_rds_cluster` + writer instance (+ reader instances опціонально)

## Приклад використання модуля

### Приклад 1: Звичайна RDS PostgreSQL instance

```hcl
module "rds" {
  source = "./modules/rds"

  name_prefix = "myapp"
  use_aurora  = false

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr
  subnet_ids = module.vpc.private_subnet_ids

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  database_name   = "mydb"
  master_username = "admin"
  master_password = "SecurePassword123!"

  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type        = "gp3"

  multi_az            = false
  publicly_accessible = false
  storage_encrypted   = true

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot = false

  parameter_max_connections = "100"
  parameter_log_statement   = "all"
  parameter_work_mem       = "4MB"

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

### Приклад 2: Aurora PostgreSQL Cluster

```hcl
module "rds" {
  source = "./modules/rds"

  name_prefix = "myapp"
  use_aurora   = true  # Вмикаємо Aurora

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr
  subnet_ids = module.vpc.private_subnet_ids

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.large"

  database_name   = "mydb"
  master_username = "admin"
  master_password = "SecurePassword123!"

  # Aurora-specific
  aurora_reader_count = 2  # Створюємо 2 reader instances

  multi_az            = true
  publicly_accessible = false
  storage_encrypted   = true

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot = false

  parameter_max_connections = "200"
  parameter_log_statement   = "all"
  parameter_work_mem       = "8MB"

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

### Приклад 3: MySQL RDS Instance

```hcl
module "rds" {
  source = "./modules/rds"

  name_prefix = "myapp"
  use_aurora  = false

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr
  subnet_ids = module.vpc.private_subnet_ids

  engine         = "mysql"  # MySQL замість PostgreSQL
  engine_version = "8.0.35"
  instance_class = "db.t3.medium"

  database_name   = "mydb"
  master_username = "admin"
  master_password = "SecurePassword123!"

  allocated_storage    = 50
  max_allocated_storage = 200
  storage_type        = "gp3"

  multi_az            = true  # Multi-AZ для високої доступності
  publicly_accessible = false
  storage_encrypted   = true

  backup_retention_period = 14
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot = false

  # MySQL параметри (work_mem ігнорується для MySQL)
  parameter_max_connections = "150"
  parameter_log_statement   = "all"

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Опис змінних модуля

### Основні змінні

| Змінна | Тип | Опис | Обов'язкова | За замовчуванням |
|--------|-----|------|-------------|------------------|
| `name_prefix` | `string` | Префікс для назв ресурсів | Так | - |
| `use_aurora` | `bool` | Створити Aurora кластер (true) або RDS instance (false) | Ні | `false` |
| `vpc_id` | `string` | ID VPC для розміщення БД | Так | - |
| `vpc_cidr` | `string` | CIDR блок VPC | Так | - |
| `subnet_ids` | `list(string)` | Список ID приватних підмереж | Так | - |

### Конфігурація бази даних

| Змінна | Тип | Опис | Обов'язкова | За замовчуванням |
|--------|-----|------|-------------|------------------|
| `engine` | `string` | Тип БД: `postgres` або `mysql` | Так | - |
| `engine_version` | `string` | Версія движка БД | Ні | `15.4` |
| `instance_class` | `string` | Клас інстансу (напр., `db.t3.medium`) | Ні | `db.t3.medium` |
| `database_name` | `string` | Назва бази даних | Так | - |
| `master_username` | `string` | Ім'я користувача адміністратора | Так | - |
| `master_password` | `string` | Пароль адміністратора (sensitive) | Так | - |

### RDS-специфічні змінні (ігноруються для Aurora)

| Змінна | Тип | Опис | За замовчуванням |
|--------|-----|------|------------------|
| `allocated_storage` | `number` | Початковий обсяг сховища в GB | `20` |
| `max_allocated_storage` | `number` | Максимальний обсяг сховища в GB | `100` |
| `storage_type` | `string` | Тип сховища (`gp3`, `gp2`, `io1`) | `gp3` |

### Aurora-специфічні змінні

| Змінна | Тип | Опис | За замовчуванням |
|--------|-----|------|------------------|
| `aurora_reader_count` | `number` | Кількість reader instances | `0` |

### Загальні налаштування

| Змінна | Тип | Опис | За замовчуванням |
|--------|-----|------|------------------|
| `multi_az` | `bool` | Увімкнути Multi-AZ розгортання | `false` |
| `publicly_accessible` | `bool` | Публічний доступ до БД | `false` |
| `storage_encrypted` | `bool` | Шифрування сховища | `true` |
| `backup_retention_period` | `number` | Період збереження backup в днях | `7` |
| `backup_window` | `string` | Вікно для backup (напр., `03:00-04:00`) | `03:00-04:00` |
| `maintenance_window` | `string` | Вікно для maintenance (напр., `mon:04:00-mon:05:00`) | `mon:04:00-mon:05:00` |
| `skip_final_snapshot` | `bool` | Пропустити фінальний snapshot при видаленні | `false` |
| `enabled_cloudwatch_logs_exports` | `list(string)` | Список типів логів для CloudWatch | `[]` |

### Parameter Group налаштування

| Змінна | Тип | Опис | За замовчуванням |
|--------|-----|------|------------------|
| `parameter_max_connections` | `string` | Максимальна кількість з'єднань | `100` |
| `parameter_log_statement` | `string` | Налаштування логування (PostgreSQL: `none`, `ddl`, `mod`, `all`) | `all` |
| `parameter_work_mem` | `string` | Робоча пам'ять в MB (тільки PostgreSQL) | `4MB` |

### Додаткові змінні

| Змінна | Тип | Опис | За замовчуванням |
|--------|-----|------|------------------|
| `allowed_security_group_ids` | `list(string)` | Список security group IDs з дозволом доступу | `[]` |
| `tags` | `map(string)` | Теги для ресурсів | `{}` |

## Outputs модуля

### Спільні outputs

- `db_subnet_group_id` - ID DB subnet group
- `db_subnet_group_name` - Назва DB subnet group
- `security_group_id` - ID security group
- `database_endpoint` - Endpoint бази даних (працює для обох типів)
- `database_port` - Порт бази даних
- `database_name` - Назва бази даних
- `master_username` - Ім'я користувача (sensitive)

### RDS Instance outputs (коли `use_aurora = false`)

- `rds_instance_id` - ID RDS instance
- `rds_instance_arn` - ARN RDS instance
- `rds_instance_endpoint` - Endpoint RDS instance
- `rds_instance_address` - Адреса RDS instance
- `rds_instance_port` - Порт RDS instance

### Aurora Cluster outputs (коли `use_aurora = true`)

- `aurora_cluster_id` - ID Aurora cluster
- `aurora_cluster_arn` - ARN Aurora cluster
- `aurora_cluster_endpoint` - Writer endpoint Aurora cluster
- `aurora_cluster_reader_endpoint` - Reader endpoint Aurora cluster
- `aurora_cluster_database_name` - Назва бази даних в кластері
- `aurora_cluster_port` - Порт Aurora cluster

## Як змінити тип БД, engine, клас інстансу

### Зміна типу БД (RDS ↔ Aurora)

Просто змініть значення `use_aurora`:

```hcl
# Для звичайної RDS
use_aurora = false

# Для Aurora кластера
use_aurora = true
```

### Зміна engine (PostgreSQL ↔ MySQL)

```hcl
# PostgreSQL
engine         = "postgres"
engine_version = "15.4"  # або інша версія

# MySQL
engine         = "mysql"
engine_version = "8.0.35"  # або інша версія
```

**Важливо**: При зміні engine потрібно також змінити `engine_version` на відповідну версію для обраного engine.

### Зміна класу інстансу

```hcl
# Для RDS
instance_class = "db.t3.medium"    # General purpose
instance_class = "db.t3.large"     # Більше ресурсів
instance_class = "db.r6g.large"    # Memory optimized

# Для Aurora
instance_class = "db.r6g.large"    # Memory optimized (рекомендовано)
instance_class = "db.r6g.xlarge"  # Більше ресурсів
```

**Доступні класи інстансів**:
- **General Purpose**: `db.t3.micro`, `db.t3.small`, `db.t3.medium`, `db.t3.large`
- **Memory Optimized**: `db.r6g.large`, `db.r6g.xlarge`, `db.r6g.2xlarge`
- **Burstable Performance**: `db.t4g.micro`, `db.t4g.small`, `db.t4g.medium`

### Зміна розміру сховища (тільки для RDS)

```hcl
allocated_storage     = 50   # Початковий розмір в GB
max_allocated_storage = 200  # Максимальний розмір для auto-scaling
storage_type         = "gp3" # Тип сховища
```

### Додавання reader instances для Aurora

```hcl
aurora_reader_count = 2  # Створить 2 reader instances
```

## Кроки використання

### 1. Налаштування Terraform Backend

1. Створіть файл `terraform.tfvars` на основі `terraform.tfvars.example`:

```hcl
aws_region          = "us-east-1"
name_prefix         = "myapp"
s3_bucket_name      = "your-terraform-state-bucket"
dynamodb_table_name = "terraform-state-lock"

# RDS Configuration
use_aurora = false
rds_engine = "postgres"
rds_engine_version = "15.4"
rds_instance_class = "db.t3.medium"
rds_database_name = "mydb"
rds_master_username = "admin"
rds_master_password = "SecurePassword123!"
```

2. Спочатку створіть S3 бакет та DynamoDB:

```bash
terraform init
terraform apply -target=module.s3_backend
```

3. Оновіть `backend.tf` з реальними значеннями та повторно ініціалізуйте:

```bash
terraform init -migrate-state
```

### 2. Застосування Terraform

```bash
terraform plan
terraform apply
```

### 3. Перевірка результатів

```bash
# Перевірка outputs
terraform output

# Перевірка RDS instance (якщо use_aurora = false)
terraform output rds_instance_id
terraform output rds_instance_endpoint

# Перевірка Aurora cluster (якщо use_aurora = true)
terraform output aurora_cluster_id
terraform output aurora_cluster_endpoint
terraform output aurora_cluster_reader_endpoint
```

## Підключення до бази даних

### PostgreSQL

```bash
# Отримайте endpoint
ENDPOINT=$(terraform output -raw database_endpoint)
PORT=$(terraform output -raw database_port)

# Підключення через psql
psql -h $ENDPOINT -p $PORT -U admin -d mydb
```

### MySQL

```bash
# Отримайте endpoint
ENDPOINT=$(terraform output -raw database_endpoint)
PORT=$(terraform output -raw database_port)

# Підключення через mysql client
mysql -h $ENDPOINT -P $PORT -u admin -p mydb
```

## Troubleshooting

### Помилка: "InvalidParameterValue: The parameter group family does not match"

Переконайтеся, що `engine_version` відповідає обраному `engine`:
- PostgreSQL: `15.4`, `14.9`, `13.12`, тощо
- MySQL: `8.0.35`, `8.0.34`, `5.7.44`, тощо

### Помилка: "InvalidParameterCombination: Multi-AZ is not supported for db.t2.micro"

Деякі класи інстансів не підтримують Multi-AZ. Використайте:
- `db.t3.micro` замість `db.t2.micro`
- Або встановіть `multi_az = false`

### Aurora не створюється

Переконайтеся, що:
- `use_aurora = true`
- `engine` встановлено правильно (`postgres` або `mysql`)
- `engine_version` підтримується для Aurora

## Безпека

⚠️ **Важливо**: 

1. **Ніколи не зберігайте паролі в коді або Git**
   - Використовуйте AWS Secrets Manager
   - Або передавайте через змінні середовища

2. **Використовуйте `publicly_accessible = false`** для продакшн середовищ

3. **Увімкніть `storage_encrypted = true`** для шифрування даних

4. **Налаштуйте правильні security groups** для обмеження доступу

## Видалення ресурсів

```bash
terraform destroy
```

**Увага**: Якщо `skip_final_snapshot = false`, буде створено фінальний snapshot перед видаленням.

## Додаткові ресурси

- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- [Terraform AWS Provider - RDS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- [Terraform AWS Provider - Aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)

