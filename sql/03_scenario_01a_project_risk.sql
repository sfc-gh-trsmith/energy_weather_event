-- ============================================================================
-- Scenario 01a: Oil & Gas Project Risk Assessment (Find)
-- ============================================================================
-- Purpose: Tables for weather-driven capital project delay risk assessment
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- ============================================================================
-- DIM_PROJECT: Capital projects (drilling, construction, infrastructure)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_PROJECT (
    PROJECT_KEY NUMBER(38,0) PRIMARY KEY,
    PROJECT_ID VARCHAR(50) NOT NULL UNIQUE,
    PROJECT_NAME VARCHAR(200) NOT NULL,
    PROJECT_TYPE VARCHAR(100) NOT NULL, -- 'Drilling', 'Pipeline', 'Facility Construction', 'Well Completion'
    SITE_KEY NUMBER(38,0) NOT NULL,
    -- Project attributes
    PROJECT_MANAGER VARCHAR(200),
    PORTFOLIO VARCHAR(100), -- 'Permian Basin', 'Gulf Coast', 'Bakken'
    WBS_HIERARCHY VARIANT, -- JSON structure
    -- Schedule
    PLANNED_START_DATE DATE NOT NULL,
    PLANNED_END_DATE DATE NOT NULL,
    BASELINE_DURATION_DAYS NUMBER(10,0),
    -- Budget
    APPROVED_BUDGET_USD NUMBER(18,2),
    BUDGET_CATEGORY VARCHAR(50), -- 'CapEx', 'OpEx'
    -- Status
    PROJECT_STATUS VARCHAR(50) NOT NULL, -- 'Planning', 'Active', 'On Hold', 'Complete'
    CURRENT_SCHEDULE_VARIANCE_DAYS NUMBER(10,0),
    CURRENT_COST_VARIANCE_USD NUMBER(18,2),
    -- KPIs
    PLANNED_CAPACITY NUMBER(18,4), -- Barrels, MCF, MW, etc.
    CAPACITY_UNIT VARCHAR(50),
    IN_SERVICE_DATE DATE,
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_PROJECT_SITE FOREIGN KEY (SITE_KEY) REFERENCES DIM_SITE(SITE_KEY)
)
COMMENT = 'Project dimension - capital projects subject to weather delays';

-- ============================================================================
-- DIM_ACTIVITY: Project activities (from P6/MS Project)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_ACTIVITY (
    ACTIVITY_KEY NUMBER(38,0) PRIMARY KEY,
    ACTIVITY_ID VARCHAR(100) NOT NULL UNIQUE, -- From P6
    ACTIVITY_NAME VARCHAR(500) NOT NULL,
    PROJECT_KEY NUMBER(38,0) NOT NULL,
    -- Activity classification
    ACTIVITY_TYPE VARCHAR(100), -- 'Drilling', 'Foundation', 'Installation', 'Commissioning'
    WBS_CODE VARCHAR(100),
    WBS_LEVEL NUMBER(2,0),
    -- Critical path
    IS_CRITICAL_PATH BOOLEAN NOT NULL DEFAULT FALSE,
    FLOAT_DAYS NUMBER(10,2), -- Total float
    FREE_FLOAT_DAYS NUMBER(10,2),
    -- Baseline schedule
    PLANNED_START_DATE DATE,
    PLANNED_END_DATE DATE,
    PLANNED_DURATION_DAYS NUMBER(10,0),
    -- Predecessors/Successors
    PREDECESSOR_IDS VARCHAR(1000), -- Comma-separated list
    SUCCESSOR_IDS VARCHAR(1000),
    -- Weather sensitivity
    WEATHER_SENSITIVE BOOLEAN DEFAULT TRUE,
    WEATHER_CONSTRAINTS VARCHAR(500), -- 'No rain', 'Wind < 20mph', etc.
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_ACTIVITY_PROJECT FOREIGN KEY (PROJECT_KEY) REFERENCES DIM_PROJECT(PROJECT_KEY)
)
COMMENT = 'Activity dimension - project tasks from scheduling systems';

-- ============================================================================
-- DIM_DELAY_TYPE: Root cause categories for delays
-- ============================================================================
CREATE OR REPLACE TABLE DIM_DELAY_TYPE (
    DELAY_TYPE_KEY NUMBER(38,0) PRIMARY KEY,
    DELAY_CODE VARCHAR(50) NOT NULL UNIQUE,
    DELAY_CATEGORY VARCHAR(100) NOT NULL, -- 'Weather', 'Labor', 'Material', 'Equipment', 'Permit'
    DELAY_SUBCATEGORY VARCHAR(100),
    ROOT_CAUSE_DETAIL VARCHAR(500),
    IS_WEATHER_RELATED BOOLEAN NOT NULL DEFAULT FALSE,
    -- Metadata
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Delay type dimension - categorization of project delays';

-- ============================================================================
-- FCT_PROJECT_ACTIVITY_SNAPSHOT: Daily snapshot of activity progress
-- ============================================================================
CREATE OR REPLACE TABLE FCT_PROJECT_ACTIVITY_SNAPSHOT (
    SNAPSHOT_KEY NUMBER(38,0) PRIMARY KEY,
    PROJECT_KEY NUMBER(38,0) NOT NULL,
    ACTIVITY_KEY NUMBER(38,0) NOT NULL,
    SNAPSHOT_TIME_KEY NUMBER(38,0) NOT NULL,
    -- Schedule metrics
    ACTUAL_START_DATE DATE,
    ACTUAL_END_DATE DATE,
    FORECAST_START_DATE DATE,
    FORECAST_END_DATE DATE,
    ACTUAL_DURATION_DAYS NUMBER(10,0),
    REMAINING_DURATION_DAYS NUMBER(10,0),
    PERCENT_COMPLETE NUMBER(5,2), -- 0-100
    SCHEDULE_VARIANCE_DAYS NUMBER(10,2),
    -- Cost metrics
    BUDGETED_COST_USD NUMBER(18,2),
    ACTUAL_COST_USD NUMBER(18,2),
    EARNED_VALUE_USD NUMBER(18,2),
    COST_VARIANCE_USD NUMBER(18,2),
    COST_COMMITMENT_USD NUMBER(18,2),
    -- Performance indices
    SPI NUMBER(10,4), -- Schedule Performance Index
    CPI NUMBER(10,4), -- Cost Performance Index
    -- Status
    ACTIVITY_STATUS VARCHAR(50), -- 'Not Started', 'In Progress', 'Complete', 'On Hold'
    -- Metadata
    SNAPSHOT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_SNAPSHOT_PROJECT FOREIGN KEY (PROJECT_KEY) REFERENCES DIM_PROJECT(PROJECT_KEY),
    CONSTRAINT FK_SNAPSHOT_ACTIVITY FOREIGN KEY (ACTIVITY_KEY) REFERENCES DIM_ACTIVITY(ACTIVITY_KEY),
    CONSTRAINT FK_SNAPSHOT_TIME FOREIGN KEY (SNAPSHOT_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Activity snapshot fact - daily progress tracking for project activities';

-- ============================================================================
-- FCT_PROJECT_DELAY_EVENT: Historical delay events (for ML training)
-- ============================================================================
CREATE OR REPLACE TABLE FCT_PROJECT_DELAY_EVENT (
    DELAY_EVENT_KEY NUMBER(38,0) PRIMARY KEY,
    PROJECT_KEY NUMBER(38,0) NOT NULL,
    ACTIVITY_KEY NUMBER(38,0) NOT NULL,
    DELAY_TYPE_KEY NUMBER(38,0) NOT NULL,
    EVENT_TIME_KEY NUMBER(38,0) NOT NULL,
    -- Delay metrics
    DELAY_START_DATE DATE NOT NULL,
    DELAY_END_DATE DATE,
    DELAY_DURATION_DAYS NUMBER(10,2) NOT NULL,
    DELAY_COST_USD NUMBER(18,2),
    -- Weather correlation
    WEATHER_SEVERITY_AT_EVENT NUMBER(3,0), -- Weather score at time of delay
    TEMPERATURE_C_AT_EVENT NUMBER(10,2),
    PRECIPITATION_MM_AT_EVENT NUMBER(10,2),
    WIND_SPEED_KPH_AT_EVENT NUMBER(10,2),
    -- Impact
    CRITICAL_PATH_IMPACT_DAYS NUMBER(10,2),
    PROJECT_COMPLETION_IMPACT_DAYS NUMBER(10,2),
    -- Description
    DELAY_DESCRIPTION VARCHAR(1000),
    ROOT_CAUSE_NOTES VARCHAR(2000),
    MITIGATION_ACTIONS VARCHAR(2000),
    -- Metadata
    EVENT_RECORDED_AT TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_DELAY_PROJECT FOREIGN KEY (PROJECT_KEY) REFERENCES DIM_PROJECT(PROJECT_KEY),
    CONSTRAINT FK_DELAY_ACTIVITY FOREIGN KEY (ACTIVITY_KEY) REFERENCES DIM_ACTIVITY(ACTIVITY_KEY),
    CONSTRAINT FK_DELAY_TYPE FOREIGN KEY (DELAY_TYPE_KEY) REFERENCES DIM_DELAY_TYPE(DELAY_TYPE_KEY),
    CONSTRAINT FK_DELAY_TIME FOREIGN KEY (EVENT_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Delay event fact - historical delays for ML model training';
