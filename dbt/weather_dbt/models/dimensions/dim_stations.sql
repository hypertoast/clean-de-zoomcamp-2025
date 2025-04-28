-- models/dimensions/dim_stations.sql
SELECT DISTINCT
  station_id,
  station_name,
  latitude,
  longitude,
  -- Add geographical classification
  CASE
    WHEN latitude > 66.5 THEN 'Arctic/Antarctic'
    WHEN latitude > 23.5 THEN 'Temperate'
    WHEN latitude > -23.5 THEN 'Tropical'
    WHEN latitude > -66.5 THEN 'Temperate'
    ELSE 'Arctic/Antarctic'
  END as climate_zone
FROM {{ ref('stg_weather_data') }}
WHERE station_id IS NOT NULL
