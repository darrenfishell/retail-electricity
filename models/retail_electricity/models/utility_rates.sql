{{ config( materialized='table') }}

SELECT
    start_date,
    CASE
        WHEN utility ILIKE '%BHD%' THEN 'BANGOR HYDRO DISTRICT'
        WHEN utility ILIKE '%MPS%' THEN 'MAINE PUBLIC SERVICE'
        ELSE 'CENTRAL MAINE POWER CO.'
    END AS utility,
    std_offer_rate
FROM {{ source('retail_electricity', 'standard_offer_df') }}
UNION ALL
SELECT * FROM (VALUES
    (DATE '2025-01-01', 'CENTRAL MAINE POWER CO.', 0.106128),
    (DATE '2025-01-01', 'MAINE PUBLIC SERVICE', 0.116530),
    (DATE '2025-01-01', 'BANGOR HYDRO DISTRICT', 0.105628),
    (DATE '2024-01-01', 'CENTRAL MAINE POWER CO.', 0.106363),
    (DATE '2024-01-01', 'MAINE PUBLIC SERVICE', 0.112850),
    (DATE '2024-01-01', 'BANGOR HYDRO DISTRICT', 0.102630)
) AS t(start_date, utility, std_offer_rate)