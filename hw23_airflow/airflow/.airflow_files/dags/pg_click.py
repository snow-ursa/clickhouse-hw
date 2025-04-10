from datetime import datetime

from airflow import DAG
from airflow.hooks.base_hook import BaseHook
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

from clickhouse_driver import Client
import pandas as pd 
from sqlalchemy import create_engine



default_args = {
    'owner': 'airflow',
}


FILENAME_TEMPLATE = 'data_{table}.csv'
TABLES_LIST = [
    'flights',
    'airports_data',
]


class PostgresConnection:
    def __init__(
        self,
        conn_str: str,
    ):
        self.conn_str = conn_str
        self.engine = create_engine(self.conn_str)


class ClickHouseConnection:
    def __init__(
        self,
        conf: dict
    ):
        self.client = Client(**conf)

def read_pg_dataframe(
    table: str, 
    pg_conn: PostgresConnection, 
    **kwargs,
) -> pd.DataFrame:

    df = pd.read_sql_query(
        f'select * from {table}',
        con=pg_conn.engine,
    )

    filename = FILENAME_TEMPLATE.format(table=table)
    df.to_csv(filename, index=False)
    
    kwargs['ti'].xcom_push(key=table, value=filename)


def write_click_dataframe(
    table: str,
    click_conn: ClickHouseConnection,
    **kwargs,
):
    
    path = kwargs['ti'].xcom_pull(
        key=table, 
        task_ids=f'postgres.get_pg_{table}',
    )
    print(path)

    df = pd.read_csv(path)

    click_conn.client.insert_dataframe(
        f'insert into demo.{table} values', 
        df,
    )


with DAG(
    'postgres_to_clickhouse',
    default_args=default_args,
    description='Transfer data from Postgres to ClickHouse',
    schedule_interval='@daily',
    start_date=datetime(2025, 4, 9),
    tags=['pg', 'click'],
    catchup=False,
    max_active_runs=1,
) as dag:

    with TaskGroup(group_id='postgres') as task_group:

        pg_conn_uri = BaseHook.get_connection('pg_conn').get_uri().replace('postgres', 'postgresql')
        pg_conn = PostgresConnection(pg_conn_uri)

        for table in TABLES_LIST:
            PythonOperator(
                task_id=f"get_pg_{table}",
                python_callable=read_pg_dataframe,
                op_kwargs={'table': table, 'pg_conn': pg_conn},
                provide_context=True,
                retries=0,
            )

    with TaskGroup(group_id='click') as task_group2:

        click_bh = BaseHook.get_connection('click_conn')
        conf = {
            'host': click_bh.host,
            'port': click_bh.port,
            'user': click_bh.login,
            'password': click_bh._password,
            'settings': {'use_numpy': True},
        }
        click_conn = ClickHouseConnection(conf)

        for table in TABLES_LIST:
            PythonOperator(
                task_id=f'write_click_{table}',
                python_callable=write_click_dataframe,
                op_kwargs={
                    'table': table,
                    'click_conn': click_conn,
                },
                provide_context=True,
                retries=0,
            )
            
    task_group >> task_group2
