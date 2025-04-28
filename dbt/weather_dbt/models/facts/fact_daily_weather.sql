-- models/facts/fact_daily_weather.sql
SELECT
  w.date,
  w.station_id,
  s.station_name,
  s.latitude,
  s.longitude,
  s.climate_zone,
  w.avg_temperature,
  w.max_temperature,
  w.min_temperature,
  w.precipitation,
  w.wind_speed,
  w.visibility,
  CASE
    WHEN w.precipitation > 0.5 THEN 'Heavy Rain'
    WHEN w.precipitation > 0.1 THEN 'Light Rain'
    WHEN w.precipitation > 0 THEN 'Drizzle'
    ELSE 'No Rain'
  END as precipitation_category,
  CASE
    WHEN w.avg_temperature > 30 THEN 'Very Hot'
    WHEN w.avg_temperature > 25 THEN 'Hot'
    WHEN w.avg_temperature > 15 THEN 'Warm'
    WHEN w.avg_temperature > 5 THEN 'Cool'
    WHEN w.avg_temperature > -5 THEN 'Cold'
    ELSE 'Very Cold'
  END as temperature_category
FROM {{ ref('stg_weather_data') }} w
JOIN {{ ref('dim_stations') }} s ON w.station_id = s.station_id
