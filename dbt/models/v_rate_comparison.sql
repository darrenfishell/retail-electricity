{{ config(materialized='view') }}

SELECT
	eia.year,
	eia.utility_name,
	eia.grid_operator,
	eia.res_kwh_rate,
	eia.res_revenue,
	eia.res_sales_kwh,
	eia.com_kwh_rate,
	eia.com_revenue,
	eia.com_sales_kwh,
	wso.weighted_standard_offer,
	(eia.res_kwh_rate - wso.weighted_standard_offer) * eia.res_sales_kwh as res_cost_variance,
	(eia.com_kwh_rate - wso.weighted_standard_offer) * eia.com_sales_kwh as com_cost_variance,
	res_cost_variance + com_cost_variance as combined_variance
FROM {{ ref('maine_eia') }} eia
JOIN {{ ref('weighted_standard_offer') }} wso
ON eia.grid_operator = wso.grid_operator
    AND eia.year = wso.year