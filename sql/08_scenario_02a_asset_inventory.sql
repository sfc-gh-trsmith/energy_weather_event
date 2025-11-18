-- ============================================================================
-- Scenario 02a: Oil & Gas Asset & Inventory Readiness (Produce & Move)
-- ============================================================================
-- Purpose: Tables for predictive asset failure and spare parts location
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- ============================================================================
-- DIM_WAREHOUSE: Spare parts storage locations
-- ============================================================================
CREATE OR REPLACE TABLE DIM_WAREHOUSE (
    WAREHOUSE_KEY NUMBER(38,0) PRIMARY KEY,
    WAREHOUSE_ID VARCHAR(50) NOT NULL UNIQUE,
    WAREHOUSE_NAME VARCHAR(200) NOT NULL,
    WAREHOUSE_TYPE VARCHAR(50) NOT NULL, -- 'Distribution Center', 'Field Depot', 'Regional Hub'
    ADDRESS VARCHAR(500),
    SITE_KEY NUMBER(38,0), -- Link to DIM_SITE if co-located
    -- Geospatial
    LATITUDE NUMBER(10,6) NOT NULL,
    LONGITUDE NUMBER(10,6) NOT NULL,
    WAREHOUSE_LOCATION GEOGRAPHY,
    -- Capacity
    TOTAL_CAPACITY_SQ_FT NUMBER(18,2),
    CURRENT_UTILIZATION_PERCENT NUMBER(5,2),
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_WAREHOUSE_SITE FOREIGN KEY (SITE_KEY) REFERENCES DIM_SITE(SITE_KEY)
)
COMMENT = 'Warehouse dimension - spare parts storage locations';

-- ============================================================================
-- DIM_SKU: Spare parts catalog
-- ============================================================================
CREATE OR REPLACE TABLE DIM_SKU (
    SKU_KEY NUMBER(38,0) PRIMARY KEY,
    SKU_ID VARCHAR(50) NOT NULL UNIQUE,
    PART_NUMBER VARCHAR(100) NOT NULL,
    PART_NAME VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(1000),
    -- Classification
    PART_CATEGORY VARCHAR(100), -- 'Rotating Equipment', 'Valves', 'Electrical', 'Instrumentation'
    PART_SUBCATEGORY VARCHAR(100),
    CRITICALITY VARCHAR(50), -- 'Critical', 'Important', 'Standard'
    -- Specifications
    MANUFACTURER VARCHAR(200),
    VENDOR VARCHAR(200),
    UNIT_OF_MEASURE VARCHAR(50),
    WEIGHT_LBS NUMBER(18,4),
    DIMENSIONS VARCHAR(100),
    -- Financial
    UNIT_COST_USD NUMBER(18,2),
    LEAD_TIME_DAYS NUMBER(10,0),
    REORDER_POINT NUMBER(10,0),
    ECONOMIC_ORDER_QUANTITY NUMBER(10,0),
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'SKU dimension - spare parts catalog';

-- ============================================================================
-- DIM_BOM: Bill of Materials (Asset to SKU mapping)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_BOM (
    BOM_KEY NUMBER(38,0) PRIMARY KEY,
    ASSET_TYPE VARCHAR(100) NOT NULL, -- Links to DIM_ASSET.ASSET_TYPE
    SKU_KEY NUMBER(38,0) NOT NULL,
    REQUIRED_QUANTITY NUMBER(10,2) NOT NULL DEFAULT 1,
    CRITICALITY_LEVEL VARCHAR(50), -- 'Critical', 'High', 'Medium', 'Low'
    MTBF_HOURS NUMBER(18,2), -- Mean Time Between Failures
    TYPICAL_REPLACEMENT_INTERVAL_DAYS NUMBER(10,0),
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_BOM_SKU FOREIGN KEY (SKU_KEY) REFERENCES DIM_SKU(SKU_KEY)
)
COMMENT = 'BOM bridge table - maps asset types to required spare parts';

-- ============================================================================
-- DIM_FAILURE_TYPE: Equipment failure classifications
-- ============================================================================
CREATE OR REPLACE TABLE DIM_FAILURE_TYPE (
    FAILURE_TYPE_KEY NUMBER(38,0) PRIMARY KEY,
    FAILURE_CODE VARCHAR(50) NOT NULL UNIQUE,
    FAILURE_NAME VARCHAR(200) NOT NULL,
    FAILURE_CATEGORY VARCHAR(100) NOT NULL, -- 'Mechanical', 'Electrical', 'Instrumentation', 'Structural'
    DESCRIPTION VARCHAR(1000),
    TYPICAL_CAUSES VARCHAR(1000),
    IS_WEATHER_RELATED BOOLEAN DEFAULT FALSE,
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Failure type dimension - equipment failure classifications';

-- ============================================================================
-- DIM_PRODUCTION_UNIT: Production facilities/lines
-- ============================================================================
CREATE OR REPLACE TABLE DIM_PRODUCTION_UNIT (
    PRODUCTION_UNIT_KEY NUMBER(38,0) PRIMARY KEY,
    PRODUCTION_UNIT_ID VARCHAR(50) NOT NULL UNIQUE,
    UNIT_NAME VARCHAR(200) NOT NULL,
    UNIT_TYPE VARCHAR(100) NOT NULL, -- 'Well', 'Production Line', 'Processing Plant', 'Pipeline'
    PRODUCT_FAMILY VARCHAR(100), -- 'Crude Oil', 'Natural Gas', 'NGL', 'Refined Products'
    SITE_KEY NUMBER(38,0) NOT NULL,
    -- Capacity
    NOMINAL_RATE_UNITS_PER_HOUR NUMBER(18,4),
    CAPACITY_UNIT VARCHAR(50), -- 'BBL/day', 'MCF/day', 'BBL/hour'
    -- Hierarchy
    UNIT_HIERARCHY VARIANT, -- JSON structure
    -- Location
    LATITUDE NUMBER(10,6),
    LONGITUDE NUMBER(10,6),
    UNIT_LOCATION GEOGRAPHY,
    -- Status
    UNIT_STATUS VARCHAR(50), -- 'Active', 'Maintenance', 'Decommissioned'
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_PRODUCTION_SITE FOREIGN KEY (SITE_KEY) REFERENCES DIM_SITE(SITE_KEY)
)
COMMENT = 'Production unit dimension - production facilities and lines';

-- ============================================================================
-- DIM_IMPACT_MODE: Production impact modes (aligned to OEE)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_IMPACT_MODE (
    IMPACT_MODE_KEY NUMBER(38,0) PRIMARY KEY,
    IMPACT_MODE_CODE VARCHAR(50) NOT NULL UNIQUE,
    MODE_NAME VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(1000),
    OEE_CATEGORY VARCHAR(50) NOT NULL, -- 'Availability', 'Performance', 'Quality'
    SEVERITY VARCHAR(50), -- 'Full Stop', 'Major', 'Minor'
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Impact mode dimension - production impact categorization';

-- ============================================================================
-- BRG_PRODUCTION_UNIT_ASSET: Production unit to asset associations
-- ============================================================================
CREATE OR REPLACE TABLE BRG_PRODUCTION_UNIT_ASSET (
    BRIDGE_KEY NUMBER(38,0) PRIMARY KEY,
    PRODUCTION_UNIT_KEY NUMBER(38,0) NOT NULL,
    ASSET_KEY NUMBER(38,0) NOT NULL,
    CONTRIBUTION_FACTOR NUMBER(5,4), -- 0-1, share of constraining capacity
    BOTTLENECK_FLAG BOOLEAN DEFAULT FALSE,
    REDUNDANCY_TYPE VARCHAR(50), -- 'Series', 'Parallel', 'N+1', 'None'
    CRITICALITY_SCORE NUMBER(3,0), -- 0-100
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_BRIDGE_UNIT FOREIGN KEY (PRODUCTION_UNIT_KEY) REFERENCES DIM_PRODUCTION_UNIT(PRODUCTION_UNIT_KEY),
    CONSTRAINT FK_BRIDGE_ASSET FOREIGN KEY (ASSET_KEY) REFERENCES DIM_ASSET(ASSET_KEY)
)
COMMENT = 'Bridge table - associates production units with critical assets';

-- ============================================================================
-- FCT_ASSET_TELEMETRY: Asset sensor/SCADA data
-- ============================================================================
CREATE OR REPLACE TABLE FCT_ASSET_TELEMETRY (
    TELEMETRY_KEY NUMBER(38,0) PRIMARY KEY,
    ASSET_KEY NUMBER(38,0) NOT NULL,
    TIME_KEY NUMBER(38,0) NOT NULL,
    READING_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    -- Measurements
    VIBRATION_MM_S NUMBER(10,4),
    TEMPERATURE_C NUMBER(10,2),
    PRESSURE_PSI NUMBER(10,2),
    FLOW_RATE NUMBER(18,4),
    POWER_CONSUMPTION_KW NUMBER(18,4),
    RPM NUMBER(10,2),
    -- Status indicators
    ALARM_COUNT NUMBER(5,0),
    WARNING_COUNT NUMBER(5,0),
    UPTIME_SECONDS NUMBER(10,0),
    OPERATIONAL_STATUS VARCHAR(50), -- 'Running', 'Idle', 'Alarmed', 'Shutdown'
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_TELEMETRY_ASSET FOREIGN KEY (ASSET_KEY) REFERENCES DIM_ASSET(ASSET_KEY),
    CONSTRAINT FK_TELEMETRY_TIME FOREIGN KEY (TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Telemetry fact - hourly asset sensor readings';

-- ============================================================================
-- FCT_MAINTENANCE_HISTORY: Historical maintenance and failure events
-- ============================================================================
CREATE OR REPLACE TABLE FCT_MAINTENANCE_HISTORY (
    MAINTENANCE_KEY NUMBER(38,0) PRIMARY KEY,
    ASSET_KEY NUMBER(38,0) NOT NULL,
    FAILURE_TYPE_KEY NUMBER(38,0),
    FAILURE_TIME_KEY NUMBER(38,0) NOT NULL,
    PRODUCTION_UNIT_KEY NUMBER(38,0),
    -- Event details
    EVENT_TYPE VARCHAR(50) NOT NULL, -- 'Failure', 'Preventive Maintenance', 'Inspection'
    FAILURE_DATE DATE NOT NULL,
    REPAIR_DATE DATE,
    DOWNTIME_HOURS NUMBER(10,2),
    MAINTENANCE_COST_USD NUMBER(18,2),
    -- Impact metrics
    ESTIMATED_DERATE_PERCENT NUMBER(5,4), -- 0-1
    ESTIMATED_LOST_VOLUME_UNITS NUMBER(18,4),
    RESTORATION_TIME_HOURS NUMBER(10,2),
    -- Weather correlation
    WEATHER_SEVERITY_AT_FAILURE NUMBER(3,0),
    TEMPERATURE_C_AT_FAILURE NUMBER(10,2),
    -- Description
    FAILURE_DESCRIPTION VARCHAR(2000),
    ROOT_CAUSE VARCHAR(1000),
    CORRECTIVE_ACTION VARCHAR(2000),
    PARTS_USED VARCHAR(1000),
    -- Metadata
    EVENT_RECORDED_AT TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_MAINT_ASSET FOREIGN KEY (ASSET_KEY) REFERENCES DIM_ASSET(ASSET_KEY),
    CONSTRAINT FK_MAINT_FAILURE_TYPE FOREIGN KEY (FAILURE_TYPE_KEY) REFERENCES DIM_FAILURE_TYPE(FAILURE_TYPE_KEY),
    CONSTRAINT FK_MAINT_TIME FOREIGN KEY (FAILURE_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_MAINT_UNIT FOREIGN KEY (PRODUCTION_UNIT_KEY) REFERENCES DIM_PRODUCTION_UNIT(PRODUCTION_UNIT_KEY)
)
COMMENT = 'Maintenance history fact - failure and maintenance events';

-- ============================================================================
-- FCT_INVENTORY_ON_HAND: Spare parts inventory snapshots
-- ============================================================================
CREATE OR REPLACE TABLE FCT_INVENTORY_ON_HAND (
    INVENTORY_KEY NUMBER(38,0) PRIMARY KEY,
    WAREHOUSE_KEY NUMBER(38,0) NOT NULL,
    SKU_KEY NUMBER(38,0) NOT NULL,
    SNAPSHOT_TIME_KEY NUMBER(38,0) NOT NULL,
    -- Quantities
    ON_HAND_QUANTITY NUMBER(18,4) NOT NULL,
    ON_ORDER_QUANTITY NUMBER(18,4),
    ALLOCATED_QUANTITY NUMBER(18,4),
    AVAILABLE_QUANTITY NUMBER(18,4),
    -- Value
    TOTAL_VALUE_USD NUMBER(18,2),
    -- Status
    REORDER_NEEDED BOOLEAN,
    STOCKOUT_RISK VARCHAR(50), -- 'High', 'Medium', 'Low', 'None'
    DAYS_OF_SUPPLY NUMBER(10,2),
    -- Metadata
    SNAPSHOT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_INVENTORY_WAREHOUSE FOREIGN KEY (WAREHOUSE_KEY) REFERENCES DIM_WAREHOUSE(WAREHOUSE_KEY),
    CONSTRAINT FK_INVENTORY_SKU FOREIGN KEY (SKU_KEY) REFERENCES DIM_SKU(SKU_KEY),
    CONSTRAINT FK_INVENTORY_TIME FOREIGN KEY (SNAPSHOT_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Inventory fact - spare parts on-hand by location';

-- ============================================================================
-- FCT_PRODUCTION_VOLUME: Hourly/daily production actuals
-- ============================================================================
CREATE OR REPLACE TABLE FCT_PRODUCTION_VOLUME (
    PRODUCTION_KEY NUMBER(38,0) PRIMARY KEY,
    PRODUCTION_UNIT_KEY NUMBER(38,0) NOT NULL,
    TIME_KEY NUMBER(38,0) NOT NULL,
    -- Volume metrics
    NOMINAL_RATE_UNITS_PER_HOUR NUMBER(18,4),
    PLANNED_VOLUME_UNITS NUMBER(18,4),
    ACTUAL_VOLUME_UNITS NUMBER(18,4),
    SCRAP_UNITS NUMBER(18,4),
    -- Performance metrics
    FIRST_PASS_YIELD_PERCENT NUMBER(5,2),
    AVAILABILITY_SECONDS NUMBER(10,0),
    PERFORMANCE_RATE_PERCENT NUMBER(5,2),
    QUALITY_PERCENT NUMBER(5,2),
    OEE_PERCENT NUMBER(5,2), -- Overall Equipment Effectiveness
    -- Metadata
    PRODUCTION_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_PRODUCTION_UNIT FOREIGN KEY (PRODUCTION_UNIT_KEY) REFERENCES DIM_PRODUCTION_UNIT(PRODUCTION_UNIT_KEY),
    CONSTRAINT FK_PRODUCTION_TIME FOREIGN KEY (TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Production volume fact - actual production by unit and time';

-- ============================================================================
-- FCT_ASSET_IMPACT: Asset-level production impact attribution
-- ============================================================================
CREATE OR REPLACE TABLE FCT_ASSET_IMPACT (
    IMPACT_KEY NUMBER(38,0) PRIMARY KEY,
    ASSET_KEY NUMBER(38,0) NOT NULL,
    PRODUCTION_UNIT_KEY NUMBER(38,0) NOT NULL,
    TIME_KEY NUMBER(38,0) NOT NULL,
    IMPACT_MODE_KEY NUMBER(38,0) NOT NULL,
    -- Impact metrics
    DERATE_PERCENT NUMBER(5,4), -- 0-1, where 0 = no impact, 1 = full stop
    LOST_VOLUME_UNITS NUMBER(18,4),
    LOST_TIME_SECONDS NUMBER(10,0),
    CONSTRAINED_RATE_UNITS_PER_HOUR NUMBER(18,4),
    ATTRIBUTION_CONFIDENCE NUMBER(5,4), -- 0-1
    -- Metadata
    IMPACT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_IMPACT_ASSET FOREIGN KEY (ASSET_KEY) REFERENCES DIM_ASSET(ASSET_KEY),
    CONSTRAINT FK_IMPACT_UNIT FOREIGN KEY (PRODUCTION_UNIT_KEY) REFERENCES DIM_PRODUCTION_UNIT(PRODUCTION_UNIT_KEY),
    CONSTRAINT FK_IMPACT_TIME FOREIGN KEY (TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_IMPACT_MODE FOREIGN KEY (IMPACT_MODE_KEY) REFERENCES DIM_IMPACT_MODE(IMPACT_MODE_KEY)
)
COMMENT = 'Asset impact fact - production loss attribution to specific assets';
