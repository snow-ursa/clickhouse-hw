CREATE TABLE flights
(
    flight_id UInt64,
    flight_no String,
    scheduled_departure DateTime64(3),
    scheduled_arrival DateTime64(3),
    departure_airport LowCardinality(String),
    arrival_airport LowCardinality(String),
    status LowCardinality(String),
    aircraft_code LowCardinality(String)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(scheduled_departure)
ORDER BY flight_no
;

CREATE TABLE flights_queue
(
    flight_id UInt64,
    flight_no String,
    scheduled_departure DateTime64(3),
    scheduled_arrival DateTime64(3),
    departure_airport LowCardinality(String),
    arrival_airport LowCardinality(String),
    status LowCardinality(String),
    aircraft_code LowCardinality(String)
)
ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'host.docker.internal:29092', 
    kafka_topic_list = 'clickhouse_flights', 
    kafka_group_name = 'flights_consumer_group', 
    kafka_format = 'JSONEachRow', 
    kafka_num_consumers = 3
;

CREATE MATERIALIZED VIEW mv_flights_queue TO flights
AS SELECT
    flight_id,
    flight_no,
    scheduled_departure,
    scheduled_arrival,
    departure_airport,
    arrival_airport,
    status,
    aircraft_code
FROM flights_queue;
