import sys
import os

os.chdir(os.path.expanduser('~'))  # Change to home directory which is safe
import utils.db_access as da

db_name = 'retail_electricity'
db = da.Database(db_name)

query = '''
    SELECT *
    FROM dbt_models.v_rate_comparison
'''

data = db.return_query_as_json(query)

sys.stdout.write(data)