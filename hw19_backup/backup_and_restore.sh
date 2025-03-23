
clickhouse-backup create_remote 20250323_hw19 -t "hw19.*"

# Run on all replicas
clickhouse-backup restore_remote --rm --schema 20250323_hw19 -t "hw1.*"
clickhouse-backup delete local 20250323_hw19

# After that, run only on the first replica for each shard
clickhouse-backup restore_remote --rm 20250323_hw19 -t "hw1.*"
clickhouse-backup delete local 20250323_hw19
