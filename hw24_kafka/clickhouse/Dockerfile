FROM clickhouse/clickhouse-server:latest

RUN apt update -y
RUN apt install vim less -y 

COPY --chown=clickhouse:clickhouse clickhouse/clickhouse-server/admin.xml /etc/clickhouse-server/config.d/admin.xml
