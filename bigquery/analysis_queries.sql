-- Query 1: Monthly average temperatures by climate zone
-- This query is optimized to use the partitioning by date
SELECT
  climate_zone,
  DATE_TRUNC(date, MONTH) AS month,
  AVG(avg_temperature) AS avg_temp,
  AVG(max_temperature) AS avg_max_temp,
  AVG(min_temperature) AS avg_min_temp,
  AVG(precipitation) AS avg_precipitation
FROM `your-project-id.weather_analysis.fact_daily_weather`
WHERE date BETWEEN '2020-01-01' AND '2022-12-31'
GROUP BY climate_zone, month
ORDER BY climate_zone, month;

-- Query 2: Distribution of weather categories by station (for categorical visualization)
-- This query benefits from clustering by station_id and temperature_category
SELECT
  station_name,
  temperature_category,
  COUNT(*) AS days_count
FROM `your-project-id.weather_analysis.fact_daily_weather`
WHERE date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY station_name, temperature_category
ORDER BY station_name, days_count DESC;

-- Query 3: Temporal trend of temperature anomalies (for time series visualization)
-- This query benefits from date partitioning
SELECT
  DATE_TRUNC(date, MONTH) AS month,
  AVG(temp_monthly_anomaly) AS avg_temp_anomaly
FROM `your-project-id.weather_analysis.fact_daily_weather`
WHERE date BETWEEN '2020-01-01' AND '2022-12-31'
GROUP BY month
ORDER BY month;

-- Query 4: Correlation between temperature and precipitation
SELECT
  climate_zone,
  CORR(avg_temperature, precipitation) AS temp_precip_correlation
FROM `your-project-id.weather_analysis.fact_daily_weather`
GROUP BY climate_zone
ORDER BY climate_zone;

-- Query 5: Extreme weather events (for dashboard alerts)
SELECT
  date,
  station_name,
  climate_zone,
  avg_temperature,
  precipitation,
  wind_speed,
  weather_severity_score
FROM `your-project-id.weather_analysis.fact_daily_weather`
WHERE weather_severity_score > 20  -- Threshold for "extreme" weather
  AND date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
ORDER BY weather_severity_score DESC
LIMIT 100;