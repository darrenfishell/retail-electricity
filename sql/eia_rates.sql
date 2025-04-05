SELECT 
	make_date(year, 1, 1) AS date,
	utility_name,
	COALESCE(ba_code, 'ISNE') AS grid_operator,
	revenue,
	sales_kwh,
	customers,
	revenue / sales_kwh as kwh_rate
FROM retail_electricity_dlt.eia_df
WHERE state = 'ME'
AND ownership ILIKE '%RETAIL%'
AND customer_type = 'RESIDENTIAL'
AND service_type = 'Energy'
AND revenue > 0
