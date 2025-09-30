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

2. Переименовываем `.env.example` в корне проекта на `.env`

```bash
mv .env.example .env
```



3. Запустите проект с помощью Docker Compose:
```bash
docker-compose up -d
```


