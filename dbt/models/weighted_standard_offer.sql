{{ config(materialized='table') }}

WITH weighting as (
SELECT
		c.*,
		c.small_load_daily_kwh / SUM(c.small_load_daily_kwh) OVER (PARTITION BY YEAR(c.month),
	grid_operator) * std_offer_rate as weighted_standard_offer
FROM
    {{ ref( 'monthly_load_and_rate_class' ) }} c
)
SELECT
	YEAR(month) as year,
	grid_operator,
	SUM(weighted_standard_offer) AS weighted_standard_offer
FROM
	weighting
GROUP BY
	ALL