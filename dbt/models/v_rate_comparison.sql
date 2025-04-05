{{ config(materialized='view') }}

SELECT *
FROM {{ ref('weighted_standard_offer') }}