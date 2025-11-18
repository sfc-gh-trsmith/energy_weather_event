-- ============================================================================
-- Shared Facts: Weather data used across scenarios
-- ============================================================================
-- Purpose: Create fact tables shared by multiple scenarios
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- ============================================================================
-- FCT_WEATHER_FORECAST: Weather forecast data at hourly granularity
-- ============================================================================
CREATE OR REPLACE TABLE FCT_WEATHER_FORECAST (
    FORECAST_KEY NUMBER(38,0) PRIMARY KEY,
    SITE_KEY NUMBER(38,0) NOT NULL,
    TIME_KEY NUMBER(38,0) NOT NULL,
    WEATHER_MODEL_KEY NUMBER(38,0) NOT NULL,
    FORECAST_RUN_TIME TIMESTAMP_NTZ NOT NULL,
    -- Weather measurements
    TEMPERATURE_C NUMBER(10,2),
    TEMPERATURE_F NUMBER(10,2),
    PRECIPITATION_MM NUMBER(10,2),
    PRECIPITATION_IN NUMBER(10,2),
    WIND_SPEED_KPH NUMBER(10,2),
    WIND_SPEED_MPH NUMBER(10,2),
    WIND_DIRECTION_DEG NUMBER(5,2),
    HUMIDITY_PERCENT NUMBER(5,2),
    PRESSURE_MB NUMBER(10,2),
    -- Severe weather indicators
    LIGHTNING_DENSITY NUMBER(10,4),
    ICING_PROBABILITY NUMBER(5,4), -- 0-1
    FREEZE_PROBABILITY NUMBER(5,4), -- 0-1
    STORM_SEVERITY_SCORE NUMBER(3,0), -- 0-100
    WEATHER_SEVERITY_SCORE NUMBER(3,0), -- 0-100, composite score
    -- Weather conditions
    WEATHER_CONDITION VARCHAR(100), -- 'Clear', 'Rain', 'Snow', 'Hurricane', etc.
    WEATHER_CATEGORY VARCHAR(50), -- 'Normal', 'Severe', 'Extreme'
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_WEATHER_SITE FOREIGN KEY (SITE_KEY) REFERENCES DIM_SITE(SITE_KEY),
    CONSTRAINT FK_WEATHER_TIME FOREIGN KEY (TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_WEATHER_MODEL FOREIGN KEY (WEATHER_MODEL_KEY) REFERENCES DIM_WEATHER_MODEL(WEATHER_MODEL_KEY)
)
COMMENT = 'Weather forecast fact - hourly forecasts by site';

-- Create indexes for query performance
