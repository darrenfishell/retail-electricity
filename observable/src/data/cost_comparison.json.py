import utils.db_access as da
import sys

db_name = 'retail_electricity'
db = da.Database(db_name)

query = '''
    SELECT *
    FROM dbt_models.v_rate_comparison
'''

# Load the data
try:
    data = db.return_query_as_json(query)
except Exception as e:
    print("Error querying database:", e)
    sys.exit(1)

# Write the JSON data to a file
sys.stdout.write(data)