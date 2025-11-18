-- ============================================================================
-- Shared Dimensions: Used across multiple scenarios
-- ============================================================================
-- Purpose: Create dimension tables shared by all O&G scenarios
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- ============================================================================
-- DIM_TIME: Time dimension for all temporal joins
-- ============================================================================
CREATE OR REPLACE TABLE DIM_TIME (
    TIME_KEY NUMBER(38,0) PRIMARY KEY,
    FULL_DATE DATE NOT NULL UNIQUE,
    YEAR NUMBER(4,0) NOT NULL,
    QUARTER NUMBER(1,0) NOT NULL,
    MONTH NUMBER(2,0) NOT NULL,
    MONTH_NAME VARCHAR(20) NOT NULL,
    DAY_OF_MONTH NUMBER(2,0) NOT NULL,
    DAY_OF_WEEK NUMBER(1,0) NOT NULL,
    DAY_NAME VARCHAR(20) NOT NULL,
    WEEK_OF_YEAR NUMBER(2,0) NOT NULL,
    IS_WEEKEND BOOLEAN NOT NULL,
    IS_HOLIDAY BOOLEAN NOT NULL,
    HOLIDAY_NAME VARCHAR(100),
    FISCAL_YEAR NUMBER(4,0),
    FISCAL_QUARTER NUMBER(1,0),
    -- For hourly tracking
    HOUR NUMBER(2,0) DEFAULT 0,
    INTERVAL_START_TS TIMESTAMP_NTZ,
    INTERVAL_GRANULARITY VARCHAR(10) DEFAULT 'Day',
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Time dimension - supports daily and hourly granularity';

-- ============================================================================
-- DIM_SITE: Geographic sites/locations for projects and operations
-- ============================================================================
CREATE OR REPLACE TABLE DIM_SITE (
    SITE_KEY NUMBER(38,0) PRIMARY KEY,
    SITE_ID VARCHAR(50) NOT NULL UNIQUE,
    SITE_NAME VARCHAR(200) NOT NULL,
    SITE_TYPE VARCHAR(50) NOT NULL, -- 'Project', 'Production', 'Warehouse', etc.
    REGION VARCHAR(100) NOT NULL,
    COUNTRY VARCHAR(100) NOT NULL,
    STATE_PROVINCE VARCHAR(100),
    -- Geospatial
    LATITUDE NUMBER(10,6),
    LONGITUDE NUMBER(10,6),
    SITE_POLYGON GEOGRAPHY,
    -- Operational attributes
    SITE_READINESS_SCORE NUMBER(3,0), -- 0-100
    SITE_STATUS VARCHAR(50), -- 'Active', 'Under Construction', 'Decommissioned'
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Site dimension - geographic locations for projects and operations';

-- ============================================================================
-- DIM_WEATHER_MODEL: Weather forecast data sources
-- ============================================================================
CREATE OR REPLACE TABLE DIM_WEATHER_MODEL (
    WEATHER_MODEL_KEY NUMBER(38,0) PRIMARY KEY,
    MODEL_ID VARCHAR(50) NOT NULL UNIQUE,
    MODEL_NAME VARCHAR(200) NOT NULL, -- 'NOAA GFS', 'ECMWF', 'AccuWeather'
    SOURCE VARCHAR(200) NOT NULL,
    SOURCE_TYPE VARCHAR(50) NOT NULL, -- 'Marketplace', 'API', 'File'
    UPDATE_FREQUENCY_HOURS NUMBER(5,2),
    SPATIAL_RESOLUTION_KM NUMBER(10,2),
    TEMPORAL_RESOLUTION_HOURS NUMBER(5,2),
    FORECAST_HORIZON_HOURS NUMBER(10,0),
    -- Metadata
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Weather model dimension - sources of weather forecast data';

-- ============================================================================
-- DIM_ASSET: Physical assets (equipment) for scenarios 02a and 03
-- ============================================================================
CREATE OR REPLACE TABLE DIM_ASSET (
    ASSET_KEY NUMBER(38,0) PRIMARY KEY,
    ASSET_ID VARCHAR(50) NOT NULL UNIQUE,
    ASSET_NAME VARCHAR(200) NOT NULL,
    ASSET_TYPE VARCHAR(100) NOT NULL, -- 'Pump', 'Compressor', 'Turbine', 'Well', 'Pipeline'
    ASSET_CATEGORY VARCHAR(50), -- 'Production', 'Transportation', 'Processing'
    MODEL_NUMBER VARCHAR(100),
    MANUFACTURER VARCHAR(200),
    SERIAL_NUMBER VARCHAR(100),
    -- Hierarchy
    ASSET_HIERARCHY VARIANT, -- JSON structure
    PARENT_ASSET_KEY NUMBER(38,0),
    -- Location
    SITE_KEY NUMBER(38,0),
    LATITUDE NUMBER(10,6),
    LONGITUDE NUMBER(10,6),
    ASSET_LOCATION GEOGRAPHY,
    -- Operational attributes
    INSTALL_DATE DATE,
    COMMISSIONING_DATE DATE,
    NAMEPLATE_CAPACITY NUMBER(18,4),
    CAPACITY_UNIT VARCHAR(50),
    CRITICALITY_SCORE NUMBER(3,0), -- 0-100
    -- Status
    ASSET_STATUS VARCHAR(50), -- 'Active', 'Maintenance', 'Decommissioned'
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_ASSET_SITE FOREIGN KEY (SITE_KEY) REFERENCES DIM_SITE(SITE_KEY)
)
COMMENT = 'Asset dimension - physical equipment for production and operations';

-- ============================================================================
-- DIM_DELIVERY_POINT: Commercial delivery/pricing locations (Scenario 03)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_DELIVERY_POINT (
    DELIVERY_POINT_KEY NUMBER(38,0) PRIMARY KEY,
    DELIVERY_POINT_CODE VARCHAR(50) NOT NULL UNIQUE,
    DELIVERY_POINT_NAME VARCHAR(200) NOT NULL,
    COMMODITY VARCHAR(50) NOT NULL, -- 'Crude', 'Natural Gas', 'Power'
    MARKET_ISO_OR_PIPELINE VARCHAR(200),
    LOCATION_TYPE VARCHAR(50), -- 'Hub', 'Zone', 'Node', 'Pool', 'Meter'
    REGION VARCHAR(100),
    COUNTRY VARCHAR(100),
    STATE_PROVINCE VARCHAR(100),
    -- Geospatial
    LATITUDE NUMBER(10,6),
    LONGITUDE NUMBER(10,6),
    LOCATION_GEOGRAPHY GEOGRAPHY,
    -- Metadata
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Delivery point dimension - commercial trading delivery locations';

-- ============================================================================
-- DIM_INTERCONNECTION_POINT: Physical grid/pipeline interconnects (Scenario 03)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_INTERCONNECTION_POINT (
    INTERCONNECTION_POINT_KEY NUMBER(38,0) PRIMARY KEY,
    INTERCONNECTION_ID VARCHAR(50) NOT NULL UNIQUE,
    INTERCONNECTION_NAME VARCHAR(200) NOT NULL,
    GRID_OR_PIPELINE VARCHAR(200) NOT NULL,
    NODE_OR_METER_ID VARCHAR(100),
    BALANCING_AUTHORITY VARCHAR(200),
    VOLTAGE_OR_SEGMENT VARCHAR(100),
    -- Geospatial
    LATITUDE NUMBER(10,6),
    LONGITUDE NUMBER(10,6),
    LOCATION_GEOGRAPHY GEOGRAPHY,
    -- Metadata
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Interconnection point dimension - physical grid/pipeline connections';

-- Note: Indexes are automatically managed by Snowflake for regular tables
-- CREATE INDEX is only supported on Hybrid Tables

