{{ config(materialized='table') }}

SELECT
    year AS year,
    utility_name,
    COALESCE(ba_code, 'ISNE') AS grid_operator,
    revenue,
    sales_kwh,
    customers,
    revenue / sales_kwh as kwh_rate
FROM {{source('retail_electricity', 'eia_df')}}
WHERE state = 'ME'
AND ownership ILIKE '%RETAIL%'
AND customer_type = 'RESIDENTIAL'
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