
--------- 1 shard 4 replica

CREATE TABLE hw15.menu_local ON CLUSTER 'all-replicated'
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
) ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}/{all_replicated_shard}', '{all_replicated_replica}')
ORDER BY id;

CREATE TABLE hw15.menu ON CLUSTER 'all-replicated'
    AS hw15.menu_local ENGINE = Distributed('all-replicated', hw15, menu_local, rand());


--------- 2 shard 2 replica

CREATE TABLE hw15.dish_local ON CLUSTER main 
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
ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}/{shard}', '{replica}')
ORDER BY id;

CREATE TABLE hw15.dish ON CLUSTER main 
    AS hw15.dish_local ENGINE = Distributed(main, hw15, dish_local, rand());


--------- 4 shard 1 replica

CREATE TABLE hw15.menu_page_local on cluster 'all-sharded'
(
    id UInt32,
    menu_id UInt32,
    page_number UInt16,
    image_id String,
    full_height UInt16,
    full_width UInt16,
    uuid UUID
) 
ENGINE = ReplicatedMergeTree('/clickhouse/{database}/{table}/{all_sharded_shard}', '{all_sharded_replica}')
ORDER BY id;

CREATE TABLE hw15.menu_page on cluster 'all-sharded' 
    AS hw15.menu_page_local ENGINE = Distributed('all-sharded', hw15, menu_page_local, rand());



---------

SELECT
    hostName() AS host,
    _shard_num AS shard_num,
    count(*) AS cnt
FROM hw15.menu
GROUP BY
    host,
    shard_num;

SELECT
    cluster,
    shard_num,
    shard_weight,
    replica_num,
    host_name
FROM system.clusters
WHERE cluster != 'default';
