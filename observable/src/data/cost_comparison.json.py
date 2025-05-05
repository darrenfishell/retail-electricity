import utils.db_access as da
import sys

db_name = 'retail_electricity'
db = da.Database(db_name)

print(f"Database object attributes: {vars(db)}", file=sys.stderr)

query = '''
    SELECT *
    FROM dbt_models.v_rate_comparison
'''

query = '''SELECT 1 as test'''

# Load the data
try:
    data = db.return_query_as_json(query)
    print(f"Data: {data}", file=sys.stderr)
except Exception as e:
    print("Error querying database:", e)
    sys.exit(1)

# Write the JSON data to a file
sys.stdout.write(data)