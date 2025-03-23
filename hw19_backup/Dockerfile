FROM clickhouse/clickhouse-server:latest

RUN apt update -y
RUN apt install vim less -y 

RUN wget https://github.com/Altinity/clickhouse-backup/releases/download/v2.4.2/clickhouse-backup-linux-amd64.tar.gz
RUN tar -xf clickhouse-backup-linux-amd64.tar.gz
RUN install -o root -g root -m 0755  build/linux/amd64/clickhouse-backup /usr/local/bin

RUN rm clickhouse-backup-linux-amd64.tar.gz
# /usr/local/bin/clickhouse-backup -v

RUN mkdir /etc/clickhouse-backup
# clickhouse-backup default-config > /etc/clickhouse-backup/config.yml
COPY clickhouse-backup/config.yml /etc/clickhouse-backup/config.yml
RUN chown -R clickhouse:clickhouse /etc/clickhouse-backup

COPY clickhouse-server/*.xml /etc/clickhouse-server/config.d/
RUN chown -R clickhouse:clickhouse /etc/clickhouse-server/config.d
