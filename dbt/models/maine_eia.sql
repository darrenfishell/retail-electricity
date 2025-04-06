{{ config(materialized='table') }}

WITH cep as (
	SELECT
		year AS year,
		utility_name,
		COALESCE(ba_code, 'ISNE') AS grid_operator,
		customer_type,
		revenue,
		sales_kwh,
		customers,
		revenue / sales_kwh as kwh_rate
	FROM {{source('retail_electricity', 'eia_df')}}
	WHERE state = 'ME'
	AND ownership ILIKE '%RETAIL%'
	AND service_type = 'Energy'
    AND revenue > 0
	-- EXCLUDE STANDARD OFFER SUPPLIERS --
	AND (
	    utility_name NOT ILIKE '%New Brunswick Power Generation%'
        AND utility_name NOT ILIKE '%NEPM%'
        AND utility_name NOT ILIKE '%NextEra%'
        AND utility_name NOT ILIKE 'CECG%'
        AND utility_name NOT ILIKE 'Competitive Energy Services%'
    )
)
SELECT
	r.year,
	r.utility_name,
	r.grid_operator,
	r.revenue as res_revenue,
	r.sales_kwh as res_sales_kwh,
	r.customers as res_customers,
	r.kwh_rate as res_kwh_rate,
	c.revenue as com_revenue,
	c.sales_kwh as com_sales_kwh,
	c.customers as com_customers,
	c.kwh_rate as com_kwh_rate
FROM cep r
LEFT JOIN cep c
ON r.year = c.year
AND r.utility_name = c.utility_name
WHERE r.customer_type = 'RESIDENTIAL'
AND c.customer_type = 'COMMERCIAL'
ORDER BY r.utility_name, r.year