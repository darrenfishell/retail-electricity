{{ config(materialized='table') }}

WITH standard_offer as (
	SELECT
		start_date,
		COALESCE(
			LEAD(start_date)
			OVER (PARTITION BY utility ORDER BY start_date)
			- INTERVAL 1 DAY
			, CURRENT_DATE )
		as end_date,
		utility,
		std_offer_rate
	FROM {{ source('retail_electricity', 'standard_offer_df') }}
)
SELECT
  utility,
  CASE
    WHEN utility = 'MAINE PUBLIC SERVICE'
        THEN 'NBSO'
        ELSE 'ISNE'
    END AS grid_operator,
  month,
  std_offer_rate
FROM standard_offer,
  generate_series(
    DATE_TRUNC('month', start_date),
    DATE_TRUNC('month', end_date),
    INTERVAL 1 MONTH
  ) AS t(month)