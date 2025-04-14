import subprocess
import os
from dlt_pipeline.pipeline import pipeline, all_data

load_info = pipeline.run(all_data(), write_disposition='replace')
print(load_info)

dbt_path = os.path.abspath('dbt')

subprocess.run([
    "dbt", "run",
    "--project-dir", dbt_path
],
    cwd="dbt"
    , check=True)