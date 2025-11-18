-- ============================================================================
-- Load Weather Forecast Fact Data
-- ============================================================================
-- Purpose: Generate realistic weather forecast data for all sites
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Generate FCT_WEATHER_FORECAST data
-- Note: This generates daily weather for 2024-2025 with some severe events
-- ============================================================================
INSERT INTO FCT_WEATHER_FORECAST (
    FORECAST_KEY, SITE_KEY, TIME_KEY, WEATHER_MODEL_KEY, FORECAST_RUN_TIME,
    TEMPERATURE_C, TEMPERATURE_F, PRECIPITATION_MM, PRECIPITATION_IN,
    WIND_SPEED_KPH, WIND_SPEED_MPH, WIND_DIRECTION_DEG, HUMIDITY_PERCENT,
    PRESSURE_MB, LIGHTNING_DENSITY, ICING_PROBABILITY, FREEZE_PROBABILITY,
    STORM_SEVERITY_SCORE, WEATHER_SEVERITY_SCORE, WEATHER_CONDITION, WEATHER_CATEGORY
)
WITH weather_sim AS (
    SELECT
        s.SITE_KEY,
        t.TIME_KEY,
        t.FULL_DATE,
        1 AS WEATHER_MODEL_KEY, -- NOAA GFS
        DATEADD(hour, -6, t.FULL_DATE::TIMESTAMP_NTZ) AS FORECAST_RUN_TIME,
        s.LATITUDE,
        s.REGION,
        -- Add some seasonal variation and randomness
        -- Base temperature by latitude and season
        CASE 
            WHEN MONTH(t.FULL_DATE) IN (12, 1, 2) THEN -- Winter
                CASE 
                    WHEN s.LATITUDE > 45 THEN UNIFORM(-20, 5, RANDOM())
                    WHEN s.LATITUDE > 35 THEN UNIFORM(-5, 15, RANDOM())
                    ELSE UNIFORM(5, 20, RANDOM())
                END
            WHEN MONTH(t.FULL_DATE) IN (6, 7, 8) THEN -- Summer
                CASE 
                    WHEN s.LATITUDE > 45 THEN UNIFORM(15, 30, RANDOM())
                    WHEN s.LATITUDE > 35 THEN UNIFORM(25, 40, RANDOM())
                    ELSE UNIFORM(28, 42, RANDOM())
                END
            ELSE -- Spring/Fall
                CASE 
                    WHEN s.LATITUDE > 45 THEN UNIFORM(0, 20, RANDOM())
                    WHEN s.LATITUDE > 35 THEN UNIFORM(10, 25, RANDOM())
                    ELSE UNIFORM(15, 30, RANDOM())
                END
        END AS TEMP_C,
        -- Precipitation (mm) - higher in summer for Gulf Coast
        CASE
            WHEN s.REGION = 'Gulf Coast' AND MONTH(t.FULL_DATE) IN (6, 7, 8, 9) THEN 
                UNIFORM(0, 80, RANDOM())
            WHEN MONTH(t.FULL_DATE) IN (4, 5, 6) THEN 
                UNIFORM(0, 40, RANDOM())
            ELSE 
                UNIFORM(0, 20, RANDOM())
        END AS PRECIP_MM,
        -- Wind speed (kph)
        UNIFORM(5, 40, RANDOM()) AS WIND_KPH,
        -- Wind direction
        UNIFORM(0, 360, RANDOM()) AS WIND_DIR,
        -- Humidity
        UNIFORM(30, 90, RANDOM()) AS HUMIDITY,
        -- Pressure
        UNIFORM(980, 1030, RANDOM()) AS PRESSURE
    FROM DIM_SITE s
    CROSS JOIN DIM_TIME t
    WHERE t.FULL_DATE BETWEEN '2024-01-01' AND '2025-12-31'
      AND s.IS_CURRENT = TRUE
      AND s.SITE_TYPE IN ('Project', 'Production')
)
SELECT
    ROW_NUMBER() OVER (ORDER BY SITE_KEY, TIME_KEY) AS FORECAST_KEY,
    SITE_KEY,
    TIME_KEY,
    WEATHER_MODEL_KEY,
    FORECAST_RUN_TIME,
    ROUND(TEMP_C, 1) AS TEMPERATURE_C,
    ROUND(TEMP_C * 9/5 + 32, 1) AS TEMPERATURE_F,
    ROUND(PRECIP_MM, 1) AS PRECIPITATION_MM,
    ROUND(PRECIP_MM * 0.0394, 2) AS PRECIPITATION_IN,
    ROUND(WIND_KPH, 1) AS WIND_SPEED_KPH,
    ROUND(WIND_KPH * 0.621371, 1) AS WIND_SPEED_MPH,
    ROUND(WIND_DIR, 0) AS WIND_DIRECTION_DEG,
    ROUND(HUMIDITY, 0) AS HUMIDITY_PERCENT,
    ROUND(PRESSURE, 1) AS PRESSURE_MB,
    -- Lightning (higher in summer, higher in Gulf Coast)
    CASE 
        WHEN REGION = 'Gulf Coast' AND MONTH(FULL_DATE) IN (6, 7, 8) THEN UNIFORM(0, 0.5, RANDOM())
        ELSE UNIFORM(0, 0.1, RANDOM())
    END AS LIGHTNING_DENSITY,
    -- Icing probability (winter, freezing temps)
    CASE 
        WHEN TEMP_C < 0 AND PRECIP_MM > 5 THEN LEAST(0.9, (0 - TEMP_C) / 10 * PRECIP_MM / 20)
        ELSE 0
    END AS ICING_PROBABILITY,
    -- Freeze probability
    CASE 
        WHEN TEMP_C < 0 THEN GREATEST(0.5, LEAST(0.95, (0 - TEMP_C) / 15))
        WHEN TEMP_C < 5 THEN 0.2
        ELSE 0
    END AS FREEZE_PROBABILITY,
    -- Storm severity (based on wind + precip)
    CASE 
        WHEN WIND_KPH > 70 AND PRECIP_MM > 50 THEN 90
        WHEN WIND_KPH > 60 AND PRECIP_MM > 30 THEN 75
        WHEN WIND_KPH > 50 OR PRECIP_MM > 40 THEN 60
        WHEN WIND_KPH > 40 OR PRECIP_MM > 25 THEN 40
        ELSE 10
    END AS STORM_SEVERITY_SCORE,
    -- Overall weather severity (composite)
    GREATEST(
        CASE WHEN ABS(TEMP_C) > 35 THEN 70 WHEN ABS(TEMP_C) > 30 THEN 50 ELSE 10 END,
        CASE WHEN WIND_KPH > 60 THEN 80 WHEN WIND_KPH > 45 THEN 60 WHEN WIND_KPH > 35 THEN 40 ELSE 10 END,
        CASE WHEN PRECIP_MM > 50 THEN 85 WHEN PRECIP_MM > 30 THEN 65 WHEN PRECIP_MM > 20 THEN 45 ELSE 10 END,
        CASE WHEN TEMP_C < -10 THEN 75 WHEN TEMP_C < 0 THEN 50 ELSE 10 END
    ) AS WEATHER_SEVERITY_SCORE,
    -- Weather condition
    CASE 
        WHEN WIND_KPH > 70 AND PRECIP_MM > 50 THEN 'Hurricane/Severe Storm'
        WHEN WIND_KPH > 60 THEN 'High Wind Warning'
        WHEN PRECIP_MM > 40 THEN 'Heavy Rain'
        WHEN PRECIP_MM > 10 AND TEMP_C < 0 THEN 'Snow/Ice'
        WHEN TEMP_C < -10 THEN 'Extreme Cold'
        WHEN TEMP_C > 40 THEN 'Extreme Heat'
        WHEN PRECIP_MM > 5 THEN 'Rain'
        WHEN PRECIP_MM > 0 THEN 'Light Rain'
        ELSE 'Clear/Partly Cloudy'
    END AS WEATHER_CONDITION,
    -- Weather category
    CASE 
        WHEN WIND_KPH > 60 OR PRECIP_MM > 40 OR TEMP_C < -10 OR TEMP_C > 40 THEN 'Extreme'
        WHEN WIND_KPH > 45 OR PRECIP_MM > 25 OR TEMP_C < 0 OR TEMP_C > 35 THEN 'Severe'
        ELSE 'Normal'
    END AS WEATHER_CATEGORY
FROM weather_sim;

-- ============================================================================
-- Add some specific severe weather events for demo purposes
-- ============================================================================

-- Hurricane event in Gulf Coast (September 2024)
UPDATE FCT_WEATHER_FORECAST
SET 
    WEATHER_SEVERITY_SCORE = 95,
    STORM_SEVERITY_SCORE = 95,
    WIND_SPEED_KPH = 120,
    WIND_SPEED_MPH = 75,
    PRECIPITATION_MM = 150,
    PRECIPITATION_IN = 5.9,
    WEATHER_CONDITION = 'Hurricane',
    WEATHER_CATEGORY = 'Extreme'
WHERE SITE_KEY IN (SELECT SITE_KEY FROM DIM_SITE WHERE REGION = 'Gulf Coast' AND SITE_TYPE = 'Project')
  AND TIME_KEY IN (SELECT TIME_KEY FROM DIM_TIME WHERE FULL_DATE BETWEEN '2024-09-15' AND '2024-09-18');

-- Winter freeze event in Permian Basin (February 2024)
UPDATE FCT_WEATHER_FORECAST
SET 
    WEATHER_SEVERITY_SCORE = 85,
    TEMPERATURE_C = -15,
    TEMPERATURE_F = 5,
    FREEZE_PROBABILITY = 0.95,
    ICING_PROBABILITY = 0.7,
    WIND_SPEED_KPH = 55,
    WIND_SPEED_MPH = 34,
    WEATHER_CONDITION = 'Extreme Cold/Ice',
    WEATHER_CATEGORY = 'Extreme'
WHERE SITE_KEY IN (SELECT SITE_KEY FROM DIM_SITE WHERE REGION = 'Permian Basin' AND SITE_TYPE = 'Project')
  AND TIME_KEY IN (SELECT TIME_KEY FROM DIM_TIME WHERE FULL_DATE BETWEEN '2024-02-10' AND '2024-02-14');

-- Severe thunderstorms in Eagle Ford (June 2024)
UPDATE FCT_WEATHER_FORECAST
SET 
    WEATHER_SEVERITY_SCORE = 75,
    STORM_SEVERITY_SCORE = 75,
    PRECIPITATION_MM = 80,
    PRECIPITATION_IN = 3.1,
    LIGHTNING_DENSITY = 0.8,
    WIND_SPEED_KPH = 65,
    WIND_SPEED_MPH = 40,
    WEATHER_CONDITION = 'Severe Thunderstorms',
    WEATHER_CATEGORY = 'Severe'
WHERE SITE_KEY IN (SELECT SITE_KEY FROM DIM_SITE WHERE REGION = 'Eagle Ford Shale' AND SITE_TYPE = 'Project')
  AND TIME_KEY IN (SELECT TIME_KEY FROM DIM_TIME WHERE FULL_DATE BETWEEN '2024-06-20' AND '2024-06-23');

-- Blizzard in Bakken (January 2025)
UPDATE FCT_WEATHER_FORECAST
SET 
    WEATHER_SEVERITY_SCORE = 90,
    TEMPERATURE_C = -25,
    TEMPERATURE_F = -13,
    FREEZE_PROBABILITY = 0.99,
    ICING_PROBABILITY = 0.9,
    WIND_SPEED_KPH = 75,
    WIND_SPEED_MPH = 47,
    PRECIPITATION_MM = 40,
    PRECIPITATION_IN = 1.6,
    WEATHER_CONDITION = 'Blizzard',
    WEATHER_CATEGORY = 'Extreme'
WHERE SITE_KEY IN (SELECT SITE_KEY FROM DIM_SITE WHERE REGION = 'Bakken Formation' AND SITE_TYPE = 'Project')
  AND TIME_KEY IN (SELECT TIME_KEY FROM DIM_TIME WHERE FULL_DATE BETWEEN '2025-01-18' AND '2025-01-22');

