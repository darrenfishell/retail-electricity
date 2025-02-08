import duckdb
import os
from contextlib import contextmanager
from pathlib import Path

data_path = Path(__file__).parents[1].joinpath('data')
data_path.mkdir(exist_ok=True)

class Database:
    def __init__(self, db_name='database'):
        self.db_path = Path(data_path, db_name + '.duckdb')

    @contextmanager
    def duckdb_connection(self):
        conn = duckdb.connect(self.db_path)
        try:
            yield conn
        finally:
            conn.close()

    def reload_data(self, df_dict):
        with self.duckdb_connection() as conn:
            for table_name, df in df_dict.items():
                statement = f'''
                    CREATE OR REPLACE TABLE {table_name}
                    AS SELECT * FROM df
                '''
                conn.sql(statement)

    def execute(self, statement):
        with self.duckdb_connection() as conn:
            conn.sql(statement)