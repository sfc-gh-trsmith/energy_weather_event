-- ============================================================================
-- Scenario 03: Hedge Mismatch Early Warning System
-- ============================================================================
-- Purpose: Tables for comparing financial hedges vs physical production
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- ============================================================================
-- DIM_TRADING_BOOK: Trading books/portfolios
-- ============================================================================
CREATE OR REPLACE TABLE DIM_TRADING_BOOK (
    BOOK_KEY NUMBER(38,0) PRIMARY KEY,
    BOOK_ID VARCHAR(50) NOT NULL UNIQUE,
    BOOK_NAME VARCHAR(200) NOT NULL,
    TRADER_NAME VARCHAR(200),
    STRATEGY VARCHAR(200), -- 'Physical Hedging', 'Spread Trading', 'Basis Trading'
    COMMODITY VARCHAR(100) NOT NULL, -- 'Crude Oil', 'Natural Gas', 'NGL', 'Power'
    BUSINESS_UNIT VARCHAR(200),
    -- Risk limits
    VAR_LIMIT_USD NUMBER(18,2),
    POSITION_LIMIT_UNITS NUMBER(18,4),
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Trading book dimension - trading portfolios and books';

-- ============================================================================
-- DIM_INSTRUMENT: Trading instruments
-- ============================================================================
CREATE OR REPLACE TABLE DIM_INSTRUMENT (
    INSTRUMENT_KEY NUMBER(38,0) PRIMARY KEY,
    INSTRUMENT_ID VARCHAR(50) NOT NULL UNIQUE,
    INSTRUMENT_TYPE VARCHAR(50) NOT NULL, -- 'Future', 'Swap', 'Option', 'Physical Contract'
    INSTRUMENT_NAME VARCHAR(200) NOT NULL,
    EXCHANGE VARCHAR(200), -- 'NYMEX', 'ICE', 'OTC'
    TICKER VARCHAR(50),
    COMMODITY VARCHAR(100) NOT NULL,
    -- Contract specifications
    CONTRACT_SIZE NUMBER(18,4),
    CONTRACT_UNIT VARCHAR(50),
    DELIVERY_TERM_TYPE VARCHAR(50), -- 'Hub', 'Zone', 'Node', 'Pipeline', 'Financial'
    PRICING_BASIS VARCHAR(200),
    SETTLEMENT_TYPE VARCHAR(50), -- 'Physical', 'Cash'
    CURRENCY VARCHAR(10) DEFAULT 'USD',
    -- Metadata
    EFFECTIVE_DATE DATE NOT NULL,
    EXPIRATION_DATE DATE,
    IS_CURRENT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Instrument dimension - trading instruments and contracts';

-- ============================================================================
-- DIM_CURVE: Forward curves
-- ============================================================================
CREATE OR REPLACE TABLE DIM_CURVE (
    CURVE_KEY NUMBER(38,0) PRIMARY KEY,
    CURVE_ID VARCHAR(50) NOT NULL UNIQUE,
    CURVE_NAME VARCHAR(200) NOT NULL, -- 'WTI_FORWARD', 'HH_FORWARD', 'PERMIAN_BASIS'
    CURVE_TYPE VARCHAR(50) NOT NULL, -- 'Market_Derived', 'Model_Derived', 'Blended'
    CONSTRUCTION_METHOD VARCHAR(200), -- 'Bootstrap', 'Kriging', 'Spread-Sum'
    COMMODITY VARCHAR(100) NOT NULL,
    CURRENCY VARCHAR(10) DEFAULT 'USD',
    UNIT VARCHAR(50), -- '$/BBL', '$/MMBTU'
    FORWARD_TENOR_SCHEMA VARCHAR(200), -- 'Monthly', 'Quarterly', 'Prompt+Strips'
    ASSOCIATED_DELIVERY_POINT_KEY NUMBER(38,0),
    -- Metadata
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_CURVE_DELIVERY_POINT FOREIGN KEY (ASSOCIATED_DELIVERY_POINT_KEY) REFERENCES DIM_DELIVERY_POINT(DELIVERY_POINT_KEY)
)
COMMENT = 'Curve dimension - forward price curves';

-- ============================================================================
-- DIM_FORECAST_VERSION: Production forecast versions
-- ============================================================================
CREATE OR REPLACE TABLE DIM_FORECAST_VERSION (
    FORECAST_VERSION_KEY NUMBER(38,0) PRIMARY KEY,
    FORECAST_VERSION_ID VARCHAR(50) NOT NULL UNIQUE,
    FORECAST_NAME VARCHAR(200) NOT NULL,
    FORECAST_TYPE VARCHAR(50) NOT NULL, -- 'Operational', 'Budget', 'Rolling', 'What-If'
    FORECAST_SOURCE VARCHAR(200), -- 'SCADA Aggregation', 'Planning System', 'Manual Entry'
    FORECAST_RUN_DATE DATE NOT NULL,
    FORECAST_HORIZON_MONTHS NUMBER(5,0),
    CONFIDENCE_LEVEL VARCHAR(50), -- 'P10', 'P50', 'P90'
    -- Version control
    VERSION_NUMBER NUMBER(10,0),
    IS_OFFICIAL BOOLEAN DEFAULT FALSE,
    SUPERSEDED_BY_VERSION_KEY NUMBER(38,0),
    -- Metadata
    CREATED_BY VARCHAR(200),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Forecast version dimension - production forecast versions';

-- ============================================================================
-- FCT_ETRM_POSITIONS: ETRM system positions (financial hedges)
-- ============================================================================
CREATE OR REPLACE TABLE FCT_ETRM_POSITIONS (
    POSITION_KEY NUMBER(38,0) PRIMARY KEY,
    BOOK_KEY NUMBER(38,0) NOT NULL,
    INSTRUMENT_KEY NUMBER(38,0) NOT NULL,
    TRADE_DELIVERY_POINT_KEY NUMBER(38,0),
    DELIVERY_TIME_KEY NUMBER(38,0) NOT NULL, -- Delivery month
    SNAPSHOT_TIME_KEY NUMBER(38,0) NOT NULL, -- As-of date
    -- Position metrics
    NOTIONAL_VOLUME NUMBER(18,4) NOT NULL, -- Can be negative for short positions
    WEIGHTED_AVG_PRICE NUMBER(18,4),
    POSITION_TYPE VARCHAR(50), -- 'Long', 'Short', 'Flat'
    -- Greeks
    DELTA NUMBER(18,6),
    GAMMA NUMBER(18,6),
    VEGA NUMBER(18,6),
    THETA NUMBER(18,6),
    -- P&L
    UNREALIZED_PNL_USD NUMBER(18,2),
    REALIZED_PNL_USD NUMBER(18,2),
    -- Metadata
    SNAPSHOT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_ETRM_BOOK FOREIGN KEY (BOOK_KEY) REFERENCES DIM_TRADING_BOOK(BOOK_KEY),
    CONSTRAINT FK_ETRM_INSTRUMENT FOREIGN KEY (INSTRUMENT_KEY) REFERENCES DIM_INSTRUMENT(INSTRUMENT_KEY),
    CONSTRAINT FK_ETRM_DELIVERY_POINT FOREIGN KEY (TRADE_DELIVERY_POINT_KEY) REFERENCES DIM_DELIVERY_POINT(DELIVERY_POINT_KEY),
    CONSTRAINT FK_ETRM_DELIVERY_TIME FOREIGN KEY (DELIVERY_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_ETRM_SNAPSHOT_TIME FOREIGN KEY (SNAPSHOT_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'ETRM positions fact - financial hedge positions from trading system';

-- ============================================================================
-- FCT_PRODUCTION_FORECAST: Production forecasts (physical deliverable)
-- ============================================================================
CREATE OR REPLACE TABLE FCT_PRODUCTION_FORECAST (
    FORECAST_KEY NUMBER(38,0) PRIMARY KEY,
    ASSET_KEY NUMBER(38,0) NOT NULL, -- Or PRODUCTION_UNIT_KEY
    FORECAST_VERSION_KEY NUMBER(38,0) NOT NULL,
    DELIVERY_TIME_KEY NUMBER(38,0) NOT NULL, -- Delivery period
    -- Forecast volumes (probabilistic)
    P10_VOLUME NUMBER(18,4), -- 10th percentile (low case)
    P50_VOLUME NUMBER(18,4), -- 50th percentile (base case)
    P90_VOLUME NUMBER(18,4), -- 90th percentile (high case)
    DETERMINISTIC_VOLUME NUMBER(18,4), -- Single point forecast
    VOLUME_UNIT VARCHAR(50), -- 'BBL', 'MCF', 'MWh'
    -- Assumptions
    ASSUMED_UPTIME_PERCENT NUMBER(5,2),
    ASSUMED_RATE NUMBER(18,4),
    WEATHER_IMPACT_VOLUME NUMBER(18,4), -- Expected weather impact
    OUTAGE_IMPACT_VOLUME NUMBER(18,4), -- Known outages
    -- Confidence
    FORECAST_CONFIDENCE VARCHAR(50), -- 'High', 'Medium', 'Low'
    STANDARD_DEVIATION NUMBER(18,4),
    -- Metadata
    FORECAST_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_FORECAST_ASSET FOREIGN KEY (ASSET_KEY) REFERENCES DIM_ASSET(ASSET_KEY),
    CONSTRAINT FK_FORECAST_VERSION FOREIGN KEY (FORECAST_VERSION_KEY) REFERENCES DIM_FORECAST_VERSION(FORECAST_VERSION_KEY),
    CONSTRAINT FK_FORECAST_TIME FOREIGN KEY (DELIVERY_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Production forecast fact - physical production forecasts';

-- ============================================================================
-- FCT_CURVE_DATA: Forward curve prices and volatility
-- ============================================================================
CREATE OR REPLACE TABLE FCT_CURVE_DATA (
    CURVE_DATA_KEY NUMBER(38,0) PRIMARY KEY,
    CURVE_KEY NUMBER(38,0) NOT NULL,
    DELIVERY_TIME_KEY NUMBER(38,0) NOT NULL, -- Delivery month/period
    SNAPSHOT_TIME_KEY NUMBER(38,0) NOT NULL, -- As-of date
    -- Curve values
    PRICE NUMBER(18,4) NOT NULL,
    VOLATILITY NUMBER(10,6), -- Implied volatility if available
    BID NUMBER(18,4),
    ASK NUMBER(18,4),
    VOLUME NUMBER(18,4), -- Trading volume if market-derived
    OPEN_INTEREST NUMBER(18,4),
    -- Derived metrics
    FORWARD_PREMIUM_DISCOUNT NUMBER(18,4), -- vs spot/prompt
    CONTANGO_BACKWARDATION VARCHAR(50),
    -- Metadata
    SNAPSHOT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_CURVE_DATA_CURVE FOREIGN KEY (CURVE_KEY) REFERENCES DIM_CURVE(CURVE_KEY),
    CONSTRAINT FK_CURVE_DELIVERY_TIME FOREIGN KEY (DELIVERY_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_CURVE_SNAPSHOT_TIME FOREIGN KEY (SNAPSHOT_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Curve data fact - forward curve prices and volatility';

-- ============================================================================
-- FCT_PHYSICAL_DELIVERY: Physical delivery schedules and actuals
-- ============================================================================
CREATE OR REPLACE TABLE FCT_PHYSICAL_DELIVERY (
    DELIVERY_KEY NUMBER(38,0) PRIMARY KEY,
    PHYSICAL_DELIVERY_POINT_KEY NUMBER(38,0) NOT NULL,
    INTERVAL_TIME_KEY NUMBER(38,0) NOT NULL, -- Hour or gas day
    SNAPSHOT_TIME_KEY NUMBER(38,0) NOT NULL,
    -- Volumes
    SCHEDULED_VOLUME NUMBER(18,4),
    ACTUAL_VOLUME NUMBER(18,4),
    IMBALANCE_VOLUME NUMBER(18,4), -- Actual - Scheduled
    LOSS_FACTOR NUMBER(10,6),
    -- Attributes
    FLOW_TYPE VARCHAR(50), -- 'Scheduled', 'Actualized', 'Forecast'
    DIRECTION VARCHAR(50), -- 'Receipt', 'Delivery'
    BALANCING_PERIOD_ID VARCHAR(50),
    -- Metadata
    SNAPSHOT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_PHYSICAL_DELIVERY_POINT FOREIGN KEY (PHYSICAL_DELIVERY_POINT_KEY) REFERENCES DIM_DELIVERY_POINT(DELIVERY_POINT_KEY),
    CONSTRAINT FK_PHYSICAL_INTERVAL_TIME FOREIGN KEY (INTERVAL_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_PHYSICAL_SNAPSHOT_TIME FOREIGN KEY (SNAPSHOT_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY)
)
COMMENT = 'Physical delivery fact - nomination schedules and actual flows';

-- ============================================================================
-- FCT_MISMATCH_RISK: Output of mismatch analysis
-- ============================================================================
CREATE OR REPLACE TABLE FCT_MISMATCH_RISK (
    MISMATCH_KEY NUMBER(38,0) PRIMARY KEY,
    BOOK_KEY NUMBER(38,0) NOT NULL,
    DELIVERY_TIME_KEY NUMBER(38,0) NOT NULL, -- Delivery month
    SIMULATION_RUN_ID VARCHAR(100) NOT NULL,
    TRADE_DELIVERY_POINT_KEY NUMBER(38,0),
    FORECAST_VERSION_KEY NUMBER(38,0) NOT NULL,
    -- Mismatch analysis results
    HEDGED_VOLUME NUMBER(18,4), -- From ETRM
    P50_DELIVERABLE_VOLUME NUMBER(18,4), -- From production forecast
    P10_DELIVERABLE_VOLUME NUMBER(18,4),
    P90_DELIVERABLE_VOLUME NUMBER(18,4),
    -- Risk metrics
    MISMATCH_PROBABILITY NUMBER(5,4), -- 0-1
    EXPECTED_MISMATCH_UNITS NUMBER(18,4), -- Can be positive or negative
    P95_MISMATCH_UNITS NUMBER(18,4), -- Value at Risk
    -- Financial impact
    EXPECTED_PNL_IMPACT_USD NUMBER(18,2),
    VAR_IMPACT_USD NUMBER(18,2),
    -- Risk drivers
    PRIMARY_RISK_DRIVER VARCHAR(200),
    WEATHER_CONTRIBUTION_PERCENT NUMBER(5,2),
    OUTAGE_CONTRIBUTION_PERCENT NUMBER(5,2),
    BASIS_CONTRIBUTION_PERCENT NUMBER(5,2),
    -- Status
    RISK_LEVEL VARCHAR(50), -- 'Low', 'Medium', 'High', 'Critical'
    ALERT_TRIGGERED BOOLEAN DEFAULT FALSE,
    -- Metadata
    SIMULATION_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT FK_MISMATCH_BOOK FOREIGN KEY (BOOK_KEY) REFERENCES DIM_TRADING_BOOK(BOOK_KEY),
    CONSTRAINT FK_MISMATCH_DELIVERY_TIME FOREIGN KEY (DELIVERY_TIME_KEY) REFERENCES DIM_TIME(TIME_KEY),
    CONSTRAINT FK_MISMATCH_DELIVERY_POINT FOREIGN KEY (TRADE_DELIVERY_POINT_KEY) REFERENCES DIM_DELIVERY_POINT(DELIVERY_POINT_KEY),
    CONSTRAINT FK_MISMATCH_FORECAST_VERSION FOREIGN KEY (FORECAST_VERSION_KEY) REFERENCES DIM_FORECAST_VERSION(FORECAST_VERSION_KEY)
)
COMMENT = 'Mismatch risk fact - hedge vs physical mismatch analysis results';
