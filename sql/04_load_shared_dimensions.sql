-- ============================================================================
-- Load Shared Dimension Data
-- ============================================================================
-- Purpose: Insert sample data into shared dimension tables
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Load DIM_TIME (2 years: 2024-2025)
-- ============================================================================
INSERT INTO DIM_TIME (
    TIME_KEY, FULL_DATE, YEAR, QUARTER, MONTH, MONTH_NAME, 
    DAY_OF_MONTH, DAY_OF_WEEK, DAY_NAME, WEEK_OF_YEAR, 
    IS_WEEKEND, IS_HOLIDAY, INTERVAL_START_TS, INTERVAL_GRANULARITY
)
WITH date_range AS (
    SELECT 
        DATEADD(day, SEQ4(), '2024-01-01'::DATE) AS full_date
    FROM TABLE(GENERATOR(ROWCOUNT => 730)) -- 2 years
)
SELECT
    TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS TIME_KEY,
    full_date,
    YEAR(full_date) AS YEAR,
    QUARTER(full_date) AS QUARTER,
    MONTH(full_date) AS MONTH,
    MONTHNAME(full_date) AS MONTH_NAME,
    DAYOFMONTH(full_date) AS DAY_OF_MONTH,
    DAYOFWEEK(full_date) AS DAY_OF_WEEK,
    DAYNAME(full_date) AS DAY_NAME,
    WEEKOFYEAR(full_date) AS WEEK_OF_YEAR,
    CASE WHEN DAYOFWEEK(full_date) IN (0, 6) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
    CASE 
        WHEN TO_CHAR(full_date, 'MM-DD') IN ('01-01', '07-04', '12-25') THEN TRUE
        ELSE FALSE 
    END AS IS_HOLIDAY,
    full_date::TIMESTAMP_NTZ AS INTERVAL_START_TS,
    'Day' AS INTERVAL_GRANULARITY
FROM date_range;

-- ============================================================================
-- Load DIM_WEATHER_MODEL
-- ============================================================================
INSERT INTO DIM_WEATHER_MODEL (
    WEATHER_MODEL_KEY, MODEL_ID, MODEL_NAME, SOURCE, SOURCE_TYPE,
    UPDATE_FREQUENCY_HOURS, SPATIAL_RESOLUTION_KM, TEMPORAL_RESOLUTION_HOURS,
    FORECAST_HORIZON_HOURS, IS_ACTIVE
) VALUES
(1, 'NOAA_GFS', 'NOAA Global Forecast System', 'NOAA National Weather Service', 'Marketplace', 6, 27, 3, 384, TRUE),
(2, 'ECMWF', 'European Centre for Medium-Range Weather Forecasts', 'ECMWF', 'Marketplace', 12, 9, 3, 240, TRUE),
(3, 'ACCUWEATHER', 'AccuWeather RealityFirst', 'AccuWeather', 'Marketplace', 1, 1, 1, 168, TRUE),
(4, 'NAM', 'North American Mesoscale Model', 'NOAA', 'API', 6, 12, 1, 84, TRUE);

-- ============================================================================
-- Load DIM_SITE (Oil & Gas sites in major US basins)
-- ============================================================================
INSERT INTO DIM_SITE (
    SITE_KEY, SITE_ID, SITE_NAME, SITE_TYPE, REGION, COUNTRY, STATE_PROVINCE,
    LATITUDE, LONGITUDE, SITE_POLYGON, SITE_READINESS_SCORE, SITE_STATUS, 
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
-- Permian Basin Sites
(1, 'SITE_PERMIAN_001', 'Midland Drilling Site Alpha', 'Project', 'Permian Basin', 'USA', 'Texas', 31.9973, -102.0779, NULL, 85, 'Active', '2024-01-01', TRUE),
(2, 'SITE_PERMIAN_002', 'Delaware Basin Production Facility', 'Production', 'Permian Basin', 'USA', 'New Mexico', 32.3513, -103.8758, NULL, 92, 'Active', '2024-01-01', TRUE),
(3, 'SITE_PERMIAN_003', 'Odessa Compressor Station', 'Production', 'Permian Basin', 'USA', 'Texas', 31.8457, -102.3676, NULL, 88, 'Active', '2024-01-01', TRUE),

-- Eagle Ford Sites
(4, 'SITE_EAGLEFORD_001', 'Karnes County Well Pad', 'Project', 'Eagle Ford Shale', 'USA', 'Texas', 28.8846, -97.9003, NULL, 78, 'Active', '2024-01-01', TRUE),
(5, 'SITE_EAGLEFORD_002', 'La Salle Processing Plant', 'Production', 'Eagle Ford Shale', 'USA', 'Texas', 28.3472, -99.0848, NULL, 90, 'Active', '2024-01-01', TRUE),

-- Bakken Sites
(6, 'SITE_BAKKEN_001', 'Williston Basin Drilling Site', 'Project', 'Bakken Formation', 'USA', 'North Dakota', 48.1470, -103.6180, NULL, 70, 'Active', '2024-01-01', TRUE),
(7, 'SITE_BAKKEN_002', 'McKenzie County Production', 'Production', 'Bakken Formation', 'USA', 'North Dakota', 47.8252, -103.2571, NULL, 82, 'Active', '2024-01-01', TRUE),

-- Gulf Coast Sites
(8, 'SITE_GULF_001', 'Port Arthur Refinery Expansion', 'Project', 'Gulf Coast', 'USA', 'Texas', 29.8688, -93.9400, NULL, 95, 'Active', '2024-01-01', TRUE),
(9, 'SITE_GULF_002', 'Houston Ship Channel Terminal', 'Production', 'Gulf Coast', 'USA', 'Texas', 29.7363, -95.2671, NULL, 88, 'Active', '2024-01-01', TRUE),
(10, 'SITE_GULF_003', 'Louisiana Offshore Platform', 'Production', 'Gulf Coast', 'USA', 'Louisiana', 29.2588, -91.2067, NULL, 75, 'Active', '2024-01-01', TRUE),

-- Marcellus Shale Sites
(11, 'SITE_MARCELLUS_001', 'Pennsylvania Gas Gathering', 'Project', 'Marcellus Shale', 'USA', 'Pennsylvania', 41.2033, -77.1945, NULL, 80, 'Active', '2024-01-01', TRUE),
(12, 'SITE_MARCELLUS_002', 'West Virginia Compressor', 'Production', 'Marcellus Shale', 'USA', 'West Virginia', 39.6295, -79.9559, NULL, 85, 'Active', '2024-01-01', TRUE),

-- Warehouse/Distribution Sites
(13, 'SITE_WAREHOUSE_TX', 'Houston Distribution Center', 'Warehouse', 'Gulf Coast', 'USA', 'Texas', 29.7604, -95.3698, NULL, 100, 'Active', '2024-01-01', TRUE),
(14, 'SITE_WAREHOUSE_OK', 'Oklahoma City Parts Depot', 'Warehouse', 'Mid-Continent', 'USA', 'Oklahoma', 35.4676, -97.5164, NULL, 95, 'Active', '2024-01-01', TRUE),
(15, 'SITE_WAREHOUSE_ND', 'Williston Supply Hub', 'Warehouse', 'Bakken Formation', 'USA', 'North Dakota', 48.1467, -103.6201, NULL, 88, 'Active', '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_DELIVERY_POINT (Trading locations)
-- ============================================================================
INSERT INTO DIM_DELIVERY_POINT (
    DELIVERY_POINT_KEY, DELIVERY_POINT_CODE, DELIVERY_POINT_NAME, 
    COMMODITY, MARKET_ISO_OR_PIPELINE, LOCATION_TYPE, 
    REGION, COUNTRY, STATE_PROVINCE, LATITUDE, LONGITUDE, LOCATION_GEOGRAPHY,
    IS_ACTIVE
) VALUES
(1, 'WTI_CUSHING', 'Cushing, Oklahoma (WTI)', 'Crude', 'NYMEX', 'Hub', 'Mid-Continent', 'USA', 'Oklahoma', 35.9848, -96.7678, NULL, TRUE),
(2, 'HH', 'Henry Hub', 'Natural Gas', 'NYMEX', 'Hub', 'Gulf Coast', 'USA', 'Louisiana', 30.0044, -92.5603, NULL, TRUE),
(3, 'PERMIAN_MIDLAND', 'Midland Basin', 'Crude', 'Various Pipelines', 'Basin', 'Permian Basin', 'USA', 'Texas', 31.9973, -102.0779, NULL, TRUE),
(4, 'WAHA', 'Waha Hub', 'Natural Gas', 'Various Pipelines', 'Hub', 'Permian Basin', 'USA', 'Texas', 31.4246, -103.5721, NULL, TRUE),
(5, 'HOUSTON_SHIP', 'Houston Ship Channel', 'Crude', 'Various Pipelines', 'Terminal', 'Gulf Coast', 'USA', 'Texas', 29.7363, -95.2671, NULL, TRUE);

-- ============================================================================
-- Load DIM_INTERCONNECTION_POINT (Physical interconnects)
-- ============================================================================
INSERT INTO DIM_INTERCONNECTION_POINT (
    INTERCONNECTION_POINT_KEY, INTERCONNECTION_ID, INTERCONNECTION_NAME,
    GRID_OR_PIPELINE, NODE_OR_METER_ID, BALANCING_AUTHORITY, VOLTAGE_OR_SEGMENT,
    LATITUDE, LONGITUDE, LOCATION_GEOGRAPHY, IS_ACTIVE
) VALUES
(1, 'INTERCONN_001', 'Permian Pipeline Meter 101', 'Permian Express Pipeline', 'METER_101', 'N/A', 'Segment A', 31.9973, -102.0779, NULL, TRUE),
(2, 'INTERCONN_002', 'Gulf Coast Grid Node 45', 'ERCOT Grid', 'NODE_45', 'ERCOT', '345kV', 29.7604, -95.3698, NULL, TRUE),
(3, 'INTERCONN_003', 'Bakken Pipeline Meter 202', 'Dakota Access Pipeline', 'METER_202', 'N/A', 'Segment B', 48.1470, -103.6180, NULL, TRUE);

