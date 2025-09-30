#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    \c ${POSTGRES_DB}

    -- Таблица офисов
    CREATE TABLE offices (
        office_id SERIAL PRIMARY KEY,
        city VARCHAR(50) NOT NULL UNIQUE,  -- ЕКБ, МСК, СПБ, Краснодар
        address VARCHAR(100)
    );

    -- Таблица туров
    CREATE TABLE tours (
        tour_id SERIAL PRIMARY KEY,
        destination VARCHAR(100) NOT NULL,
        tour_type VARCHAR(50) NOT NULL,  -- пляжный, экскурсионный, горный
        price DECIMAL(10, 2) NOT NULL,
        duration_days INT NOT NULL
    );

    -- Таблица клиентов (SCD Type 2)
    CREATE TABLE customers (
        customer_surrogate_key SERIAL PRIMARY KEY,  -- Суррогатный ключ
        customer_id INT NOT NULL,  -- Бизнес-ключ (оригинальный ID клиента)
        name VARCHAR(100) NOT NULL,
        surname VARCHAR(100) NOT NULL,
        email VARCHAR(100),
        phone VARCHAR(20),
        address VARCHAR(200),
        valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
        is_current BOOLEAN DEFAULT TRUE,
        UNIQUE (customer_id, valid_from)  -- Для уникальности историй
    );
    CREATE INDEX idx_customers_id ON customers(customer_id);
    CREATE INDEX idx_customers_surname ON customers(surname);

    -- Таблица бронирований
    CREATE TABLE bookings (
        booking_id SERIAL PRIMARY KEY,
        customer_surrogate_key INT REFERENCES customers(customer_surrogate_key),
        tour_id INT REFERENCES tours(tour_id),
        office_id INT REFERENCES offices(office_id),
        booking_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(20) NOT NULL,  -- booked, paid, cancelled
        total_amount DECIMAL(10, 2) NOT NULL
    );
    CREATE INDEX idx_bookings_date ON bookings(booking_date);

    -- Таблица платежей
    CREATE TABLE payments (
        payment_id SERIAL PRIMARY KEY,
        booking_id INT REFERENCES bookings(booking_id),
        payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        amount DECIMAL(10, 2) NOT NULL,
        payment_type VARCHAR(20) NOT NULL  -- cash, card
    );


EOSQL