import os
import pandas as pd
import duckdb
from duckdb.duckdb import project

import file_transformations as ft
from pathlib import Path

project_root = Path(__file__).parent.parent
raw_data_dir = Path(project_root, 'raw_data')
raw_data_dir.mkdir(exist_ok=True)
process_dir = Path(project_root, 'prepared_data')
process_dir.mkdir(exist_ok=True)

ft.download_eia_861(end_year=2024, data_dir=raw_data_dir)
eia_df = ft.process_and_merge_861(raw_data_dir, process_dir)
migration_df = ft.process_customer_migration_files(raw_data_dir, process_dir)

data_dir = Path(Path(__file__).parent.parent, 'data')
data_dir.mkdir(exist_ok=True)

prep_path = Path(project_root, 'prepared_data')
prep_files = prep_path.iterdir()

for file in prep_files:
    df = pd.read_csv(file)

    with duckdb.connect(os.path.join(data_dir, 'retail_electricity.db')) as db:
        db.sql(f'''
            CREATE OR REPLACE TABLE {file.stem} AS
            SELECT * FROM eia_df
        ''')