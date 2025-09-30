clickhouse-client -u "$CLICKHOUSE_USER" --password "$CLICKHOUSE_PASSWORD" -q "
CREATE DATABASE IF NOT EXISTS ${CLICKHOUSE_DB};

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.office_dim (
    office_id UInt32,
    city String,
    address String
) ENGINE = MergeTree() ORDER BY office_id;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.tour_dim (
    tour_id UInt32,
    destination String,
    tour_type String,
    price Float64,
    duration_days UInt16
) ENGINE = MergeTree() ORDER BY tour_id;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.customer_dim (
    customer_surrogate_key UInt32,
    customer_id UInt32,
    name String,
    surname String,
    email String,
    phone String,
    address String,
    valid_from DateTime,
    valid_to DateTime,
    is_current UInt8
) ENGINE = ReplacingMergeTree() ORDER BY (customer_id, valid_from) PRIMARY KEY (customer_id, valid_from);

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.date_dim (
    date Date,
    year UInt16,
    month UInt8,
    day UInt8,
    quarter UInt8,
    weekday UInt8
) ENGINE = MergeTree() PARTITION BY year ORDER BY date;

CREATE TABLE IF NOT EXISTS ${CLICKHOUSE_DB}.bookings_fact (
    booking_id UInt32,
    customer_surrogate_key UInt32,
    tour_id UInt32,
    office_id UInt32,
    booking_date Date,
    status String,
    total_amount Float64,
    payment_amount Float64,
    payment_type String
) ENGINE = MergeTree() PARTITION BY toYYYYMM(booking_date) ORDER BY (booking_date, office_id);
"