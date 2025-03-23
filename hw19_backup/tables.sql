CREATE DATABASE hw19 ON CLUSTER replicated_cluster;

CREATE TABLE hw19.dish on cluster replicated_cluster 
(
    id UInt32,
    name String,
    description String,
    menus_appeared UInt32,
    times_appeared Int32,
    first_appeared UInt16,
    last_appeared UInt16,
    lowest_price Decimal64(3),
    highest_price Decimal64(3)
) 
ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}', '{replica}') 
ORDER BY id
SETTINGS storage_policy = 'tiered'
;

CREATE TABLE hw19.menu on cluster replicated_cluster 
(
    id UInt32,
    name String,
    sponsor String,
    event String,
    venue String,
    place String,
    physical_description String,
    occasion String,
    notes String,
    call_number String,
    keywords String,
    language String,
    date String,
    location String,
    location_type String,
    currency String,
    currency_symbol String,
    status String,
    page_count UInt16,
    dish_count UInt16
) ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}', '{replica}') 
ORDER BY id
SETTINGS storage_policy = 'tiered'
;

CREATE TABLE hw19.menu_page on cluster replicated_cluster 
(
    id UInt32,
    menu_id UInt32,
    page_number UInt16,
    image_id String,
    full_height UInt16,
    full_width UInt16,
    uuid UUID
) ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}', '{replica}')
ORDER BY id
SETTINGS storage_policy = 'tiered'
;

CREATE TABLE hw19.menu_item on cluster replicated_cluster 
(
    id UInt32,
    menu_page_id UInt32,
    price Decimal64(3),
    high_price Decimal64(3),
    dish_id UInt32,
    created_at DateTime,
    updated_at DateTime,
    xpos Float64,
    ypos Float64
) ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}', '{replica}') 
ORDER BY id
SETTINGS storage_policy = 'tiered'
;

---------

SELECT
    database,
    name,
    engine,
    total_rows
FROM system.tables
WHERE database = 'hw19';

---------

DROP TABLE hw19.dish ON CLUSTER replicated_cluster SYNC;
TRUNCATE TABLE hw19.menu ON CLUSTER replicated_cluster SYNC;
