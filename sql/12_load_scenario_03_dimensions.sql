-- ============================================================================
-- Load Scenario 03 Dimension Data (Hedge Mismatch Early Warning)
-- ============================================================================
-- Purpose: Insert sample data for hedge mismatch scenario
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Load DIM_TRADING_BOOK
-- ============================================================================
INSERT INTO DIM_TRADING_BOOK (
    BOOK_KEY, BOOK_ID, BOOK_NAME, TRADER_NAME, STRATEGY, COMMODITY,
    BUSINESS_UNIT, VAR_LIMIT_USD, POSITION_LIMIT_UNITS,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
(1, 'BOOK_PERMIAN_CRUDE', 'Permian Basin Crude Oil', 'Tara Johnson', 'Physical Hedging', 'Crude Oil', 'Upstream Trading', 5000000, 1000000, '2024-01-01', TRUE),
(2, 'BOOK_PERMIAN_GAS', 'Permian Basin Natural Gas', 'Marcus Chen', 'Physical Hedging', 'Natural Gas', 'Upstream Trading', 3000000, 500000, '2024-01-01', TRUE),
(3, 'BOOK_EAGLE_FORD', 'Eagle Ford Crude', 'Sarah Williams', 'Physical Hedging', 'Crude Oil', 'Upstream Trading', 4000000, 800000, '2024-01-01', TRUE),
(4, 'BOOK_GULF_COAST', 'Gulf Coast Products', 'David Martinez', 'Basis Trading', 'Crude Oil', 'Midstream Trading', 6000000, 2000000, '2024-01-01', TRUE),
(5, 'BOOK_BAKKEN', 'Bakken Crude', 'Lisa Thompson', 'Physical Hedging', 'Crude Oil', 'Upstream Trading', 3500000, 750000, '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_INSTRUMENT
-- ============================================================================
INSERT INTO DIM_INSTRUMENT (
    INSTRUMENT_KEY, INSTRUMENT_ID, INSTRUMENT_TYPE, INSTRUMENT_NAME,
    EXCHANGE, TICKER, COMMODITY, CONTRACT_SIZE, CONTRACT_UNIT,
    DELIVERY_TERM_TYPE, PRICING_BASIS, SETTLEMENT_TYPE, CURRENCY,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
-- Crude Oil Futures
(1, 'INST_CL', 'Future', 'WTI Crude Oil Future', 'NYMEX', 'CL', 'Crude Oil', 1000, 'BBL', 'Financial', 'WTI Cushing', 'Physical', 'USD', '2024-01-01', TRUE),
(2, 'INST_BZ', 'Future', 'Brent Crude Future', 'ICE', 'BZ', 'Crude Oil', 1000, 'BBL', 'Financial', 'Brent', 'Cash', 'USD', '2024-01-01', TRUE),

-- Natural Gas Futures
(3, 'INST_NG', 'Future', 'Henry Hub Natural Gas Future', 'NYMEX', 'NG', 'Natural Gas', 10000, 'MMBTU', 'Financial', 'Henry Hub', 'Physical', 'USD', '2024-01-01', TRUE),

-- Physical Contracts
(4, 'INST_PERMIAN_PHYS', 'Physical Contract', 'Permian Basin Physical Crude', 'OTC', NULL, 'Crude Oil', 1000, 'BBL', 'Pipeline', 'Midland WTI', 'Physical', 'USD', '2024-01-01', TRUE),
(5, 'INST_WAHA_PHYS', 'Physical Contract', 'Waha Hub Physical Gas', 'OTC', NULL, 'Natural Gas', 10000, 'MMBTU', 'Pipeline', 'Waha', 'Physical', 'USD', '2024-01-01', TRUE),
(6, 'INST_HSC_PHYS', 'Physical Contract', 'Houston Ship Channel Physical Crude', 'OTC', NULL, 'Crude Oil', 1000, 'BBL', 'Pipeline', 'Houston', 'Physical', 'USD', '2024-01-01', TRUE),

-- Swaps
(7, 'INST_WTI_SWAP', 'Swap', 'WTI Crude Oil Swap', 'OTC', NULL, 'Crude Oil', 1000, 'BBL', 'Financial', 'WTI', 'Cash', 'USD', '2024-01-01', TRUE),
(8, 'INST_HH_SWAP', 'Swap', 'Henry Hub Natural Gas Swap', 'OTC', NULL, 'Natural Gas', 10000, 'MMBTU', 'Financial', 'Henry Hub', 'Cash', 'USD', '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_CURVE
-- ============================================================================
INSERT INTO DIM_CURVE (
    CURVE_KEY, CURVE_ID, CURVE_NAME, CURVE_TYPE, CONSTRUCTION_METHOD,
    COMMODITY, CURRENCY, UNIT, FORWARD_TENOR_SCHEMA, ASSOCIATED_DELIVERY_POINT_KEY,
    IS_ACTIVE
) VALUES
(1, 'CURVE_WTI_FWD', 'WTI Forward Curve', 'Market_Derived', 'Bootstrap', 'Crude Oil', 'USD', '$/BBL', 'Monthly', 1, TRUE),
(2, 'CURVE_HH_FWD', 'Henry Hub Forward Curve', 'Market_Derived', 'Bootstrap', 'Natural Gas', 'USD', '$/MMBTU', 'Monthly', 2, TRUE),
(3, 'CURVE_PERMIAN_BASIS', 'Permian Basin Basis Curve', 'Model_Derived', 'Spread-Sum', 'Crude Oil', 'USD', '$/BBL', 'Monthly', 3, TRUE),
(4, 'CURVE_WAHA_BASIS', 'Waha Hub Basis Curve', 'Model_Derived', 'Spread-Sum', 'Natural Gas', 'USD', '$/MMBTU', 'Monthly', 4, TRUE),
(5, 'CURVE_HSC', 'Houston Ship Channel Curve', 'Blended', 'Spread-Sum', 'Crude Oil', 'USD', '$/BBL', 'Monthly', 5, TRUE);

-- ============================================================================
-- Load DIM_FORECAST_VERSION
-- ============================================================================
INSERT INTO DIM_FORECAST_VERSION (
    FORECAST_VERSION_KEY, FORECAST_VERSION_ID, FORECAST_NAME, FORECAST_TYPE,
    FORECAST_SOURCE, FORECAST_RUN_DATE, FORECAST_HORIZON_MONTHS, CONFIDENCE_LEVEL,
    VERSION_NUMBER, IS_OFFICIAL, CREATED_BY
) VALUES
-- 2024 Forecasts
(1, 'FCST_2024_01_OFFICIAL', 'January 2024 Official Forecast', 'Rolling', 'Planning System', '2024-01-05', 12, 'P50', 1, TRUE, 'Planning Team'),
(2, 'FCST_2024_02_OFFICIAL', 'February 2024 Official Forecast', 'Rolling', 'Planning System', '2024-02-05', 12, 'P50', 2, TRUE, 'Planning Team'),
(3, 'FCST_2024_03_OFFICIAL', 'March 2024 Official Forecast', 'Rolling', 'Planning System', '2024-03-05', 12, 'P50', 3, TRUE, 'Planning Team'),
(4, 'FCST_2024_04_OFFICIAL', 'April 2024 Official Forecast', 'Rolling', 'Planning System', '2024-04-05', 12, 'P50', 4, TRUE, 'Planning Team'),
(5, 'FCST_2024_05_OFFICIAL', 'May 2024 Official Forecast', 'Rolling', 'Planning System', '2024-05-05', 12, 'P50', 5, TRUE, 'Planning Team'),
(6, 'FCST_2024_06_OFFICIAL', 'June 2024 Official Forecast', 'Rolling', 'Planning System', '2024-06-05', 12, 'P50', 6, TRUE, 'Planning Team'),
(7, 'FCST_2024_06_WEATHER_ADJ', 'June 2024 Weather Adjusted', 'What-If', 'Manual Entry', '2024-06-20', 6, 'P50', 7, FALSE, 'Risk Team'),
(8, 'FCST_2024_09_OFFICIAL', 'September 2024 Official Forecast', 'Rolling', 'Planning System', '2024-09-05', 12, 'P50', 8, TRUE, 'Planning Team'),
(9, 'FCST_2024_09_HURRICANE', 'September 2024 Hurricane Impact', 'What-If', 'Manual Entry', '2024-09-14', 6, 'P10', 9, FALSE, 'Risk Team'),
(10, 'FCST_2025_01_OFFICIAL', 'January 2025 Official Forecast', 'Rolling', 'Planning System', '2025-01-05', 12, 'P50', 10, TRUE, 'Planning Team');

