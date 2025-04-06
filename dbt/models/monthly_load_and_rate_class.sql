{{ config(materialized='table') }}

SELECT
	mso.month,
	mso.grid_operator,
	mso.utility,
	mso.std_offer_rate,
	SUM(CASE
			WHEN ld.customer_class = 'SMALL'
			THEN ld.cep_load_mwh * 1000
		END) AS small_load_daily_kwh,
	SUM(CASE
			WHEN ld.customer_class = 'MEDIUM'
			THEN ld.cep_load_mwh * 1000
		END) AS medium_load_daily_kwh
FROM {{ ref('monthly_standard_offer') }} mso
JOIN {{ source('retail_electricity', 'load_df') }} ld
ON DATE_TRUNC('month', mso.month) = DATE_TRUNC('month', ld.date)
AND mso.utility = ld.utility
GROUP BY ALL