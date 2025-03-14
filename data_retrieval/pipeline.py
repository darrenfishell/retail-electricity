from database import Database

import file_transformations as ft
from pathlib import Path

db = Database('retail_electricity_pricing')

project_root = Path(__file__).parent.parent
raw_data_dir = Path(project_root, 'raw_data')
raw_data_dir.mkdir(exist_ok=True)

process_dir = Path(project_root, 'prepared_data')
process_dir.mkdir(exist_ok=True)

ft.download_eia_861(end_year=2024, data_dir=raw_data_dir)
eia_df = ft.process_and_merge_861(raw_data_dir, process_dir)
migration_outputs = ft.process_customer_migration_files(raw_data_dir, process_dir)
standard_offer_df = ft.get_standard_offer()

tables_to_load = {
         'EIA_SALES': eia_df,
         'STANDARD_OFFER': standard_offer_df
         } | migration_outputs

db.reload_data(tables_to_load)