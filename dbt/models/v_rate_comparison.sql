{{ config(materialized='view') }}

SELECT
	eia.year,
	eia.utility_name,
	eia.grid_operator,
	eia.revenue,
	eia.customers,
	eia.sales_kwh,
	eia.kwh_rate,
	wso.weighted_standard_offer,
	(eia.kwh_rate - wso.weighted_standard_offer) * eia.sales_kwh as res_cost_variance
FROM {{ ref('maine_eia') }} eia
JOIN {{ ref('weighted_standard_offer') }} wso
ON eia.grid_operator = wso.grid_operator
    AND eia.year = wso.year