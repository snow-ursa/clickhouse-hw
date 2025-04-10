-- postgresql 
create user demo_user with password 'secretpwd';

grant usage on schema bookings to demo_user;
grant all on all tables in schema bookings to demo_user;


-- clickhouse 
CREATE DATABASE demo;

CREATE TABLE demo.flights
(
    `flight_id` Int,
    `flight_no` String,
    `scheduled_departure` DateTime64,
    `scheduled_arrival` DateTime64,
    `departure_airport` String,
    `arrival_airport` String,
    `status` String,
    `aircraft_code` String,
    `actual_departure` DateTime64,
    `actual_arrival` DateTime64
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(scheduled_arrival)
ORDER BY (flight_no, departure_airport, arrival_airport);


CREATE TABLE demo.airports_data
(
    `airport_code` String,
    `airport_name` String,
    `city` String,
    `coordinates` String,
    `timezone` String
)
ENGINE = TinyLog
;

CREATE USER demo_user IDENTIFIED WITH plaintext_password BY 'secretpwd';
GRANT SELECT, INSERT, CREATE TABLE ON demo.* TO demo_user;
