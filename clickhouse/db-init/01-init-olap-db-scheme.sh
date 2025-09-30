clickhouse-client -u "$CLICKHOUSE_USER" --password "$CLICKHOUSE_PASSWORD" -q "
CREATE DATABASE IF NOT EXISTS ${CLICKHOUSE_DB};

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.restaurant_dim (
    restaurant_id UInt32,
    city String,
    address String,
    type String,
    open_hours String,
    square_feet UInt32,
    employee_count UInt16,
    valid_from DateTime,
    valid_to DateTime,
    is_current UInt8
) ENGINE = ReplacingMergeTree() ORDER BY (restaurant_id, valid_from) PRIMARY KEY (restaurant_id, valid_from);

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.menu_item_dim (
    item_id UInt32,
    item_version_id UInt32,
    name String,
    category String,
    price Float64,
    calories UInt32,
    is_vegan UInt8,
    description String,
    valid_from DateTime,
    valid_to DateTime,
    is_current UInt8
) ENGINE = ReplacingMergeTree() ORDER BY (item_version_id, valid_from) PRIMARY KEY (item_version_id, valid_from);

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.customer_dim (
    customer_surrogate_key UInt32,
    customer_id UInt32,
    name String,
    surname String,
    email String,
    phone String,
    address String,
    loyalty_points UInt32,
    registration_date DateTime,
    valid_from DateTime,
    valid_to DateTime,
    is_current UInt8
) ENGINE = ReplacingMergeTree() ORDER BY (customer_id, valid_from) PRIMARY KEY (customer_id, valid_from);

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.employee_dim (
    employee_id UInt32,
    name String,
    surname String,
    position String,
    hire_date DateTime,
    salary Float64,
    restaurant_id UInt32
) ENGINE = MergeTree() ORDER BY employee_id;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.promotion_dim (
    promo_id UInt32,
    name String,
    discount_percent Float64,
    start_date DateTime,
    end_date DateTime,
    description String
) ENGINE = MergeTree() ORDER BY promo_id;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.date_dim (
    date Date,
    year UInt16,
    month UInt8,
    day UInt8,
    quarter UInt8,
    weekday UInt8,
    is_holiday UInt8
) ENGINE = MergeTree() PARTITION BY year ORDER BY date;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.time_dim (
    time UInt32,
    hour UInt8,
    minute UInt8,
    period String
) ENGINE = MergeTree() ORDER BY time;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.orders_fact (
    order_id UInt32,
    customer_surrogate_key UInt32,
    restaurant_id UInt32,
    employee_id UInt32,
    item_id UInt32,
    promo_id UInt32,
    order_date Date,
    order_time UInt32,
    status String,
    quantity UInt16,
    price_at_time Float64,
    total_amount Float64,
    applied_discount Float64,
    payment_amount Float64,
    payment_type String,
    is_delivery UInt8,
    calories_consumed UInt32
) ENGINE = MergeTree() PARTITION BY toYYYYMM(order_date) ORDER BY (order_date, restaurant_id);
"