-- models/staging/stg_weather_data.sql
SELECT
  date,
  station_id,
  station_name,
  latitude,
  longitude,
  avg_temperature,
  max_temperature,
  min_temperature,
  precipitation,
  wind_speed,
  visibility,
  precipitation_category,
  temperature_category
FROM {{ source('weather_data', 'weather_data_optimized') }}
