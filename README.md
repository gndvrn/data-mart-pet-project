# data-mart-pet-project

## Структура проекта

> Все контейнеры в работе используют около 4-5 Gb ОЗУ - это было ограничение моей системы

**PostgreSQL** - OLTP-хранилище + метаданные Airflow

**Airflow** - оркестрация ETL

**Apache Spark** - single-node вариант для передачи данных между узлами

**ClickHouse** - OLAP-хранилище, колоночная база для аналитических запросов

**Apache Superset** - визуализация данных из витрин

**dbt** - трансформации данных

**MinIO** - open-source объектное S3 хранилище (эмуляция Data Lake)

## Запуск локально

> необходим docker и docker-compose


1. Клонируем репо

```bash
git clone https://github.com/gndvrn/data-mart-pet-project.git && cd data-mart-pet-project
```

2. Создаем `.env` в корне проекта с такими данными

```bash
touch .env
```

```env
# Пользователь oltp бд
POSTGRES_USER=postgres_admin
POSTGRES_PASSWORD=postgres_admin
POSTGRES_DB=oltp

# airflow имеет доступ только к своим метаданным
AIRFLOW_USER=airflow
AIRFLOW_PASSWORD=airflow
AIRFLOW_DB=aiflow

# aifrlow-ui
AIRFLOW_WWW_USER_USERNAME=airflowadmin
AIRFLOW_WWW_USER_PASSWORD=airflowadmin

AIRFLOW_UID=501  # UID твоего пользователя (узнай через id -u)
AIRFLOW_GID=0

MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin

CLICKHOUSE_USER=clickhouse_admin
CLICKHOUSE_PASSWORD=clickhouse_admin
CLICKHOUSE_DB=olap

SUPERSET_ADMIN_USERNAME=superset_admin
SUPERSET_ADMIN_EMAIL=admin@superset.com
SUPERSET_ADMIN_PASSWORD=superset_admin
# Нужно сгенерировать при помощи `openssl rand -hex 32`
SUPERSET_SECRET_KEY=...
```

3. Запустите проект с помощью Docker Compose:
```bash
docker-compose up -d
```


