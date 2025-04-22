
kafka-topics --bootstrap-server localhost:9092 --topic clickhouse_flights --create --partitions 3 --replication-factor 1

kafka-console-producer --bootstrap-server localhost:9092 --topic clickhouse_flights

kafka-console-consumer --bootstrap-server localhost:9092 --topic clickhouse_flights --from-beginning --consumer-property enable.auto.commit=false

# kafka-topics  --bootstrap-server 'localhost:9092' --delete --topic clickhouse_flights
