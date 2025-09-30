#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    \c ${POSTGRES_DB}

    -- Таблица ресторанов
    CREATE TABLE restaurants (
        restaurant_id SERIAL PRIMARY KEY,
        city VARCHAR(50) NOT NULL UNIQUE,
        address VARCHAR(100),
        type VARCHAR(20),
        open_hours VARCHAR(50),
        square_feet INT,
        employee_count INT
    );

    -- Таблица элементов меню (SCD Type 2)
    CREATE TABLE menu_items (
        item_id SERIAL PRIMARY KEY,
        item_version_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        category VARCHAR(50),
        price DECIMAL(10, 2) NOT NULL,
        calories INT,
        is_vegan BOOLEAN DEFAULT FALSE,
        description VARCHAR(200),
        valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
        is_current BOOLEAN DEFAULT TRUE,
        UNIQUE (item_version_id, valid_from)
    );

    -- Таблица клиентов (SCD Type 2)
    CREATE TABLE customers (
        customer_surrogate_key SERIAL PRIMARY KEY,
        customer_id INT NOT NULL,
        name VARCHAR(100),
        surname VARCHAR(100),
        email VARCHAR(100),
        phone VARCHAR(20),
        address VARCHAR(200),
        loyalty_points INT DEFAULT 0,
        registration_date TIMESTAMP,
        valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
        is_current BOOLEAN DEFAULT TRUE,
        UNIQUE (customer_id, valid_from)
    );
    CREATE INDEX idx_customers_id ON customers(customer_id);
    CREATE INDEX idx_customers_surname ON customers(surname);

    -- Таблица сотрудников
    CREATE TABLE employees (
        employee_id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        position VARCHAR(50),
        hire_date TIMESTAMP,
        salary DECIMAL(10, 2),
        restaurant_id INT REFERENCES restaurants(restaurant_id)
    );

    -- Таблица промоакций
    CREATE TABLE promotions (
        promo_id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        discount_percent DECIMAL(5, 2),
        start_date TIMESTAMP,
        end_date TIMESTAMP,
        description VARCHAR(200)
    );

    -- Таблица заказов
    CREATE TABLE orders (
        order_id SERIAL PRIMARY KEY,
        customer_surrogate_key INT REFERENCES customers(customer_surrogate_key),
        restaurant_id INT REFERENCES restaurants(restaurant_id) NOT NULL,
        employee_id INT REFERENCES employees(employee_id),
        order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(20) NOT NULL,
        total_amount DECIMAL(10, 2) NOT NULL,
        is_delivery BOOLEAN DEFAULT FALSE,
        delivery_address VARCHAR(200)
    );
    CREATE INDEX idx_orders_date ON orders(order_date);

    -- Таблица деталей заказа
    CREATE TABLE order_items (
        order_item_id SERIAL PRIMARY KEY,
        order_id INT REFERENCES orders(order_id) NOT NULL,
        item_id INT REFERENCES menu_items(item_id) NOT NULL,
        quantity INT NOT NULL,
        price_at_time DECIMAL(10, 2) NOT NULL
    );

    -- Таблица платежей
    CREATE TABLE payments (
        payment_id SERIAL PRIMARY KEY,
        order_id INT REFERENCES orders(order_id) NOT NULL,
        payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        amount DECIMAL(10, 2) NOT NULL,
        payment_type VARCHAR(20) NOT NULL
    );

    -- Таблица применения промо к заказам
    CREATE TABLE order_promotions (
        order_promo_id SERIAL PRIMARY KEY,
        order_id INT REFERENCES orders(order_id) NOT NULL,
        promo_id INT REFERENCES promotions(promo_id) NOT NULL,
        applied_discount DECIMAL(10, 2)
    );

EOSQL