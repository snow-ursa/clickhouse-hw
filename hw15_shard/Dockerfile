FROM clickhouse/clickhouse-server:latest

RUN apt update -y
RUN apt install vim less -y 

COPY clickhouse-server/*.xml /etc/clickhouse-server/config.d/
RUN chown -R clickhouse:clickhouse /etc/clickhouse-server/config.d
