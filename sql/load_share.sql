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
	FROM retail_electricity_dlt.standard_offer_df sod
)
, add_load_totals as (
	SELECT 
		sod.start_date,
		sod.end_date,
		sod.utility,
		CASE 
			WHEN sod.utility = 'MAINE PUBLIC SERVICE'
				THEN 'NBSO'
				ELSE 'ISNE'
		END AS grid_operator,
		sod.std_offer_rate,
		SUM(ld.cep_load_mwh) * 1000 AS load_kwh
	FROM standard_offer sod
	JOIN retail_electricity_dlt.load_df ld 
	ON ld.date BETWEEN sod.start_date AND sod.end_date
		AND sod.utility = ld.utility
	GROUP BY ALL
	ORDER BY START_DATE
)
, load_share as (
	SELECT 
		start_date,
		end_date,
		utility,
		grid_operator,
		std_offer_rate,
		load_kwh,
		load_kwh / SUM( load_kwh ) OVER (PARTITION BY start_date, grid_operator) AS share_of_load
	FROM add_load_totals
	ORDER BY start_date
)
SELECT 
	start_date,
	end_date,
	grid_operator,
	std_offer_rate
FROM load_share
WHERE grid_operator = 'NBSO'
UNION ALL 
SELECT 
	start_date,
	end_date,
	grid_operator,
	SUM( std_offer_rate::FLOAT * share_of_load ) AS std_offer_rate
FROM load_share 
WHERE grid_operator != 'NBSO'
GROUP BY ALL