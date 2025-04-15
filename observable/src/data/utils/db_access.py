import duckdb
from pathlib import Path
from contextlib import contextmanager

class Database:
    def __init__(self, db_name):
        self.db_name = db_name + '.duckdb'
        self.data_root = Path(__file__).resolve().parents[4] / 'data'
        self.db_path = self.data_root / self.db_name

    @contextmanager
    def _get_connection(self):
        conn = duckdb.connect(self.db_path, read_only=True)
        try:
            yield conn
        finally:
            conn.close()

    def return_query_as_df(self, query):
        with self._get_connection() as conn:
            return conn.sql(query).df()

    def return_query_as_json(self, query):
        with self._get_connection() as conn:
            return conn.sql(query).df().to_json(orient='records')