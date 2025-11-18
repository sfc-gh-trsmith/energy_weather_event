-- ============================================================================
-- Load Scenario 02a Fact Data (Asset & Inventory Readiness)
-- ============================================================================
-- Purpose: Generate telemetry, maintenance, inventory, and production data
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Generate FCT_INVENTORY_ON_HAND (Weekly snapshots for 2024-2025)
-- ============================================================================
INSERT INTO FCT_INVENTORY_ON_HAND (
    INVENTORY_KEY, WAREHOUSE_KEY, SKU_KEY, SNAPSHOT_TIME_KEY,
    ON_HAND_QUANTITY, ON_ORDER_QUANTITY, ALLOCATED_QUANTITY, AVAILABLE_QUANTITY,
    TOTAL_VALUE_USD, REORDER_NEEDED, STOCKOUT_RISK, DAYS_OF_SUPPLY,
    SNAPSHOT_TIMESTAMP
)
WITH inventory_sim AS (
    SELECT
        w.WAREHOUSE_KEY,
        s.SKU_KEY,
        t.TIME_KEY,
        t.FULL_DATE,
        s.UNIT_COST_USD,
        s.REORDER_POINT,
        -- Simulate inventory levels with some randomness
        GREATEST(0, UNIFORM(0, 15, RANDOM())) AS ON_HAND,
        UNIFORM(0, 5, RANDOM()) AS ON_ORDER,
        UNIFORM(0, 3, RANDOM()) AS ALLOCATED
    FROM DIM_WAREHOUSE w
    CROSS JOIN DIM_SKU s
    CROSS JOIN DIM_TIME t
    WHERE w.IS_CURRENT = TRUE
      AND s.IS_CURRENT = TRUE
      AND t.FULL_DATE BETWEEN '2024-01-01' AND '2025-12-31'
      AND DAYOFWEEK(t.FULL_DATE) = 1 -- Monday snapshots
)
SELECT
    ROW_NUMBER() OVER (ORDER BY WAREHOUSE_KEY, SKU_KEY, TIME_KEY) AS INVENTORY_KEY,
    WAREHOUSE_KEY,
    SKU_KEY,
    TIME_KEY AS SNAPSHOT_TIME_KEY,
    ON_HAND AS ON_HAND_QUANTITY,
    ON_ORDER AS ON_ORDER_QUANTITY,
    ALLOCATED AS ALLOCATED_QUANTITY,
    GREATEST(0, ON_HAND - ALLOCATED) AS AVAILABLE_QUANTITY,
    ON_HAND * UNIT_COST_USD AS TOTAL_VALUE_USD,
    CASE WHEN ON_HAND < REORDER_POINT THEN TRUE ELSE FALSE END AS REORDER_NEEDED,
    CASE 
        WHEN ON_HAND = 0 THEN 'High'
        WHEN ON_HAND < REORDER_POINT * 0.5 THEN 'High'
        WHEN ON_HAND < REORDER_POINT THEN 'Medium'
        ELSE 'Low'
    END AS STOCKOUT_RISK,
    CASE 
        WHEN ON_HAND > 0 THEN ON_HAND / GREATEST(1, REORDER_POINT / 30.0)
        ELSE 0
    END AS DAYS_OF_SUPPLY,
    FULL_DATE::TIMESTAMP_NTZ AS SNAPSHOT_TIMESTAMP
FROM inventory_sim;

-- ============================================================================
-- Generate FCT_MAINTENANCE_HISTORY (Historical failures and maintenance)
-- ============================================================================
INSERT INTO FCT_MAINTENANCE_HISTORY (
    MAINTENANCE_KEY, ASSET_KEY, FAILURE_TYPE_KEY, FAILURE_TIME_KEY,
    PRODUCTION_UNIT_KEY, EVENT_TYPE, FAILURE_DATE, REPAIR_DATE,
    DOWNTIME_HOURS, MAINTENANCE_COST_USD, ESTIMATED_DERATE_PERCENT,
    ESTIMATED_LOST_VOLUME_UNITS, RESTORATION_TIME_HOURS,
    WEATHER_SEVERITY_AT_FAILURE, TEMPERATURE_C_AT_FAILURE,
    FAILURE_DESCRIPTION, ROOT_CAUSE, CORRECTIVE_ACTION, PARTS_USED,
    EVENT_RECORDED_AT
) VALUES
-- Weather-related failures
(1, 1001, 2, 20240212, 2, 'Failure', '2024-02-12', '2024-02-14', 48, 185000, 1.0, 1000000, 48, 85, -15,
 'Compressor bearing failure due to extreme cold', 'Lubricant thickened in -15C temperatures causing bearing seizure', 
 'Replaced bearing, switched to winter-grade lubricant, installed bearing heaters', 'SKU_COMP_SEAL_001 x2', '2024-02-14 18:00:00'),

(2, 1008, 1, 20240916, 6, 'Failure', '2024-09-16', '2024-09-19', 72, 295000, 1.0, 4500000, 72, 95, 28,
 'Major seal failure during hurricane causing shutdown', 'Hurricane conditions caused debris ingestion and seal damage',
 'Replaced mechanical seals, cleaned system, enhanced filtration', 'SKU_PUMP_SEAL_001 x2, SKU_FILTER_OIL_001 x4', '2024-09-19 14:00:00'),

(3, 1006, 10, 20250120, 5, 'Failure', '2025-01-20', '2025-01-22', 36, 425000, 1.0, 900000, 36, 90, -25,
 'Freeze damage to compressor during blizzard', 'Inadequate winterization led to freeze damage in -25C conditions',
 'Replaced damaged components, enhanced winterization, installed heat tracing', 'SKU_COMP_ROTOR_001 x1, SKU_COMP_SEAL_001 x2', '2025-01-22 16:00:00'),

(4, 1004, 5, 20240715, 3, 'Failure', '2024-07-15', '2024-07-16', 18, 125000, 0.8, 360000, 18, 65, 42,
 'Motor failure due to extreme heat', 'Sustained 42C temperatures caused motor overheating and insulation breakdown',
 'Replaced motor, upgraded cooling system', 'SKU_MOTOR_ELEC_001 x1', '2024-07-16 12:00:00'),

-- Non-weather failures
(5, 1002, 4, 20240425, 1, 'Failure', '2024-04-25', '2024-04-27', 42, 145000, 0.9, 562500, 42, 25, 18,
 'Pump impeller wear causing performance degradation', 'Cavitation and erosion led to impeller degradation',
 'Replaced impeller, adjusted suction pressure', 'SKU_PUMP_IMP_001 x1', '2024-04-27 10:00:00'),

(6, 1003, 3, 20240810, NULL, 'Failure', '2024-08-10', '2024-08-14', 96, 875000, 0.0, 0, 96, 35, 32,
 'Turbine blade damage from foreign object', 'Foreign object ingestion caused blade damage',
 'Replaced blade set, enhanced inlet filtration', 'SKU_TURB_BLADE_001 x1', '2024-08-14 16:00:00'),

(7, 1007, 1, 20241110, 5, 'Failure', '2024-11-10', '2024-11-11', 24, 95000, 0.6, 450000, 24, 40, 12,
 'Seal failure causing leakage', 'Normal wear led to seal degradation',
 'Replaced seals, performed alignment check', 'SKU_PUMP_SEAL_001 x1', '2024-11-11 14:00:00'),

(8, 1005, 8, 20240605, 4, 'Preventive Maintenance', '2024-06-05', '2024-06-06', 12, 45000, 0.0, 0, 12, 30, 25,
 'Scheduled preventive maintenance', 'Routine PM per maintenance schedule',
 'Inspected all components, replaced consumables, performed alignments', 'SKU_FILTER_OIL_001 x2', '2024-06-06 08:00:00'),

-- More weather-correlated events
(9, 1009, 6, 20240622, NULL, 'Failure', '2024-06-22', '2024-06-23', 16, 185000, 0.0, 0, 16, 75, 32,
 'Sensor failures during severe thunderstorms', 'Lightning strike damaged instrumentation',
 'Replaced sensors, upgraded surge protection', 'SKU_SENSOR_VIBE_001 x4', '2024-06-23 10:00:00'),

(10, 1010, 7, 20241208, NULL, 'Failure', '2024-12-08', '2024-12-08', 4, 35000, 0.3, 0, 4, 50, -5,
 'Control valve sticking in cold weather', 'Cold temperatures caused actuator to stick',
 'Replaced actuator, installed heat tracing', 'SKU_VALVE_CTRL_001 x1', '2024-12-08 16:00:00');

-- Correlate with weather data
MERGE INTO FCT_MAINTENANCE_HISTORY mh
USING (
    SELECT 
        mh.MAINTENANCE_KEY,
        wf.WEATHER_SEVERITY_SCORE,
        wf.TEMPERATURE_C
    FROM FCT_MAINTENANCE_HISTORY mh
    JOIN DIM_ASSET a ON a.ASSET_KEY = mh.ASSET_KEY
    JOIN FCT_WEATHER_FORECAST wf ON wf.SITE_KEY = a.SITE_KEY AND wf.TIME_KEY = mh.FAILURE_TIME_KEY
    WHERE mh.WEATHER_SEVERITY_AT_FAILURE IS NULL
) src
ON mh.MAINTENANCE_KEY = src.MAINTENANCE_KEY
WHEN MATCHED THEN UPDATE SET
    mh.WEATHER_SEVERITY_AT_FAILURE = src.WEATHER_SEVERITY_SCORE,
    mh.TEMPERATURE_C_AT_FAILURE = src.TEMPERATURE_C;

-- ============================================================================
-- Generate FCT_PRODUCTION_VOLUME (Daily production for 2024)
-- ============================================================================
INSERT INTO FCT_PRODUCTION_VOLUME (
    PRODUCTION_KEY, PRODUCTION_UNIT_KEY, TIME_KEY,
    NOMINAL_RATE_UNITS_PER_HOUR, PLANNED_VOLUME_UNITS, ACTUAL_VOLUME_UNITS,
    SCRAP_UNITS, FIRST_PASS_YIELD_PERCENT, AVAILABILITY_SECONDS,
    PERFORMANCE_RATE_PERCENT, QUALITY_PERCENT, OEE_PERCENT,
    PRODUCTION_TIMESTAMP
)
WITH production_sim AS (
    SELECT
        pu.PRODUCTION_UNIT_KEY,
        t.TIME_KEY,
        t.FULL_DATE,
        pu.NOMINAL_RATE_UNITS_PER_HOUR,
        -- Calculate planned daily volume
        pu.NOMINAL_RATE_UNITS_PER_HOUR * 24 AS PLANNED_VOL,
        -- Add variance for actual production
        UNIFORM(0.75, 0.98, RANDOM()) AS PERF_FACTOR,
        UNIFORM(0.85, 1.0, RANDOM()) AS AVAIL_FACTOR,
        UNIFORM(0.95, 0.995, RANDOM()) AS QUAL_FACTOR
    FROM DIM_PRODUCTION_UNIT pu
    CROSS JOIN DIM_TIME t
    WHERE pu.IS_CURRENT = TRUE
      AND t.FULL_DATE BETWEEN '2024-01-01' AND '2024-12-31'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY PRODUCTION_UNIT_KEY, TIME_KEY) AS PRODUCTION_KEY,
    PRODUCTION_UNIT_KEY,
    TIME_KEY,
    NOMINAL_RATE_UNITS_PER_HOUR,
    PLANNED_VOL AS PLANNED_VOLUME_UNITS,
    ROUND(PLANNED_VOL * PERF_FACTOR * AVAIL_FACTOR, 2) AS ACTUAL_VOLUME_UNITS,
    ROUND(PLANNED_VOL * PERF_FACTOR * AVAIL_FACTOR * (1 - QUAL_FACTOR), 2) AS SCRAP_UNITS,
    ROUND(QUAL_FACTOR * 100, 2) AS FIRST_PASS_YIELD_PERCENT,
    ROUND(86400 * AVAIL_FACTOR, 0) AS AVAILABILITY_SECONDS,
    ROUND(PERF_FACTOR * 100, 2) AS PERFORMANCE_RATE_PERCENT,
    ROUND(QUAL_FACTOR * 100, 2) AS QUALITY_PERCENT,
    ROUND(AVAIL_FACTOR * PERF_FACTOR * QUAL_FACTOR * 100, 2) AS OEE_PERCENT,
    FULL_DATE::TIMESTAMP_NTZ AS PRODUCTION_TIMESTAMP
FROM production_sim;

-- ============================================================================
-- Generate FCT_ASSET_TELEMETRY (Hourly readings for recent month)
-- ============================================================================
INSERT INTO FCT_ASSET_TELEMETRY (
    TELEMETRY_KEY, ASSET_KEY, TIME_KEY, READING_TIMESTAMP,
    VIBRATION_MM_S, TEMPERATURE_C, PRESSURE_PSI, FLOW_RATE,
    POWER_CONSUMPTION_KW, RPM, ALARM_COUNT, WARNING_COUNT,
    UPTIME_SECONDS, OPERATIONAL_STATUS
)
WITH telemetry_sim AS (
    SELECT
        a.ASSET_KEY,
        a.ASSET_TYPE,
        t.TIME_KEY,
        t.FULL_DATE,
        -- Asset-type specific ranges
        CASE a.ASSET_TYPE
            WHEN 'Compressor' THEN UNIFORM(2.0, 8.5, RANDOM())
            WHEN 'Pump' THEN UNIFORM(1.5, 6.0, RANDOM())
            WHEN 'Turbine' THEN UNIFORM(3.0, 9.5, RANDOM())
        END AS VIBE,
        UNIFORM(40, 95, RANDOM()) AS TEMP,
        UNIFORM(250, 850, RANDOM()) AS PRESS,
        UNIFORM(0.7, 1.0, RANDOM()) AS FLOW_FACTOR,
        CASE a.ASSET_TYPE
            WHEN 'Compressor' THEN UNIFORM(1500, 3000, RANDOM())
            WHEN 'Pump' THEN UNIFORM(75, 150, RANDOM())
            WHEN 'Turbine' THEN UNIFORM(20000, 40000, RANDOM())
        END AS RPM_VAL
    FROM DIM_ASSET a
    CROSS JOIN DIM_TIME t
    WHERE a.ASSET_KEY >= 1001 -- Only new assets
      AND a.IS_CURRENT = TRUE
      AND t.FULL_DATE BETWEEN '2024-11-01' AND '2024-12-31'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY ASSET_KEY, TIME_KEY) AS TELEMETRY_KEY,
    ASSET_KEY,
    TIME_KEY,
    FULL_DATE::TIMESTAMP_NTZ AS READING_TIMESTAMP,
    ROUND(VIBE, 2) AS VIBRATION_MM_S,
    ROUND(TEMP, 1) AS TEMPERATURE_C,
    ROUND(PRESS, 1) AS PRESSURE_PSI,
    CASE ASSET_TYPE
        WHEN 'Compressor' THEN ROUND(500 * FLOW_FACTOR, 1)
        WHEN 'Pump' THEN ROUND(5000 * FLOW_FACTOR, 1)
        WHEN 'Turbine' THEN ROUND(25 * FLOW_FACTOR, 1)
    END AS FLOW_RATE,
    CASE ASSET_TYPE
        WHEN 'Compressor' THEN ROUND(UNIFORM(1800, 2200, RANDOM()), 1)
        WHEN 'Pump' THEN ROUND(UNIFORM(85, 125, RANDOM()), 1)
        WHEN 'Turbine' THEN ROUND(UNIFORM(22000, 38000, RANDOM()), 1)
    END AS POWER_CONSUMPTION_KW,
    ROUND(RPM_VAL, 0) AS RPM,
    CASE WHEN VIBE > 7.5 OR TEMP > 90 THEN 1 ELSE 0 END AS ALARM_COUNT,
    CASE WHEN VIBE > 6.5 OR TEMP > 85 THEN 1 ELSE 0 END AS WARNING_COUNT,
    3600 AS UPTIME_SECONDS,
    'Running' AS OPERATIONAL_STATUS
FROM telemetry_sim;

-- ============================================================================
-- Generate FCT_ASSET_IMPACT (Production impact attribution)
-- ============================================================================
INSERT INTO FCT_ASSET_IMPACT (
    IMPACT_KEY, ASSET_KEY, PRODUCTION_UNIT_KEY, TIME_KEY, IMPACT_MODE_KEY,
    DERATE_PERCENT, LOST_VOLUME_UNITS, LOST_TIME_SECONDS,
    CONSTRAINED_RATE_UNITS_PER_HOUR, ATTRIBUTION_CONFIDENCE,
    IMPACT_TIMESTAMP
)
SELECT
    ROW_NUMBER() OVER (ORDER BY mh.ASSET_KEY, mh.FAILURE_TIME_KEY) AS IMPACT_KEY,
    mh.ASSET_KEY,
    mh.PRODUCTION_UNIT_KEY,
    mh.FAILURE_TIME_KEY AS TIME_KEY,
    CASE 
        WHEN mh.ESTIMATED_DERATE_PERCENT = 1.0 THEN 1 -- Full Stop
        WHEN mh.ESTIMATED_DERATE_PERCENT > 0.5 THEN 2 -- Speed Loss
        ELSE 3 -- Minor Stop
    END AS IMPACT_MODE_KEY,
    mh.ESTIMATED_DERATE_PERCENT AS DERATE_PERCENT,
    mh.ESTIMATED_LOST_VOLUME_UNITS AS LOST_VOLUME_UNITS,
    mh.DOWNTIME_HOURS * 3600 AS LOST_TIME_SECONDS,
    pu.NOMINAL_RATE_UNITS_PER_HOUR * (1 - mh.ESTIMATED_DERATE_PERCENT) AS CONSTRAINED_RATE_UNITS_PER_HOUR,
    0.85 AS ATTRIBUTION_CONFIDENCE,
    mh.FAILURE_DATE::TIMESTAMP_NTZ AS IMPACT_TIMESTAMP
FROM FCT_MAINTENANCE_HISTORY mh
JOIN DIM_PRODUCTION_UNIT pu ON mh.PRODUCTION_UNIT_KEY = pu.PRODUCTION_UNIT_KEY
WHERE mh.PRODUCTION_UNIT_KEY IS NOT NULL
  AND mh.EVENT_TYPE = 'Failure';

