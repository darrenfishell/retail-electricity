import dlt
import file_transformations as ft
import pandas as pd
import os

@dlt.resource(
    primary_key=[
        'year',
        'utility_number',
        'utility_name',
        'state',
        'customer_type',
        'service_type',
        'part'
    ]
)
def eia_df(end_year=2024):
    ft.download_eia_861(end_year=end_year)
    df = ft.process_and_merge_861()
    numeric_columns = ['REVENUE', 'SALES_KWH', 'CUSTOMERS']
    df[numeric_columns] = df[numeric_columns].apply(pd.to_numeric, errors='coerce')
    yield df

@dlt.resource
def customers_df():
    customer_df, _ = ft.process_customer_migration_files()
    yield customer_df

@dlt.resource
def load_df():
    _, load_df = ft.process_customer_migration_files()
    yield load_df

@dlt.resource
def standard_offer_df():
    df = ft.get_standard_offer()
    yield df

db_path = os.path.abspath("data/retail_electricity.duckdb")

pipeline = dlt.pipeline(
    pipeline_name='retail_electricity_pipeline',
    destination=dlt.destinations.duckdb(db_path),
    dataset_name='retail_electricity_dlt'
)

@dlt.source
def all_data():
    yield eia_df()
    yield customers_df()
    yield load_df()
    yield standard_offer_df()

# Run pipeline using the generator
load_info = pipeline.run(
    all_data(),
    write_disposition='replace'
)

print(load_info)