-- ============================================================================
-- Load Scenario 02a Dimension Data (Asset & Inventory Readiness)
-- ============================================================================
-- Purpose: Insert sample data for asset and inventory scenario
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Update DIM_ASSET with additional oil & gas equipment
-- ============================================================================
INSERT INTO DIM_ASSET (
    ASSET_KEY, ASSET_ID, ASSET_NAME, ASSET_TYPE, ASSET_CATEGORY,
    MODEL_NUMBER, MANUFACTURER, SITE_KEY, LATITUDE, LONGITUDE, ASSET_LOCATION,
    INSTALL_DATE, NAMEPLATE_CAPACITY, CAPACITY_UNIT, CRITICALITY_SCORE,
    ASSET_STATUS, EFFECTIVE_DATE, IS_CURRENT
) VALUES
-- Permian Basin Assets
(1001, 'ASSET_PM_COMP_001', 'Midland Compressor C-101', 'Compressor', 'Production', 'CAT-3608', 'Caterpillar', 2, 32.3513, -103.8758, NULL, '2020-03-15', 500, 'MMCF/day', 95, 'Active', '2024-01-01', TRUE),
(1002, 'ASSET_PM_PUMP_001', 'Delaware Basin Transfer Pump P-201', 'Pump', 'Production', 'Flowserve API 610', 'Flowserve', 2, 32.3520, -103.8760, NULL, '2019-08-20', 5000, 'BBL/day', 90, 'Active', '2024-01-01', TRUE),
(1003, 'ASSET_PM_TURB_001', 'Odessa Gas Turbine GT-301', 'Turbine', 'Production', 'GE LM2500', 'General Electric', 3, 31.8457, -102.3676, NULL, '2018-11-10', 25, 'MW', 98, 'Active', '2024-01-01', TRUE),

-- Eagle Ford Assets
(1004, 'ASSET_EF_COMP_001', 'Karnes Compressor C-102', 'Compressor', 'Production', 'Ariel JGK/4', 'Ariel', 4, 28.8846, -97.9003, NULL, '2021-05-12', 350, 'MMCF/day', 88, 'Active', '2024-01-01', TRUE),
(1005, 'ASSET_EF_PUMP_002', 'La Salle NGL Pump P-401', 'Pump', 'Production', 'Sulzer CPT', 'Sulzer', 5, 28.3472, -99.0848, NULL, '2020-09-18', 3000, 'BBL/day', 85, 'Active', '2024-01-01', TRUE),

-- Bakken Assets
(1006, 'ASSET_BK_COMP_001', 'Williston Compressor C-501', 'Compressor', 'Production', 'Exterran VMY-375', 'Exterran', 6, 48.1470, -103.6180, NULL, '2019-06-25', 400, 'MMCF/day', 92, 'Active', '2024-01-01', TRUE),
(1007, 'ASSET_BK_PUMP_001', 'McKenzie Transfer Pump P-502', 'Pump', 'Production', 'Weatherford ESP', 'Weatherford', 7, 47.8252, -103.2571, NULL, '2020-11-30', 4500, 'BBL/day', 87, 'Active', '2024-01-01', TRUE),

-- Gulf Coast Assets
(1008, 'ASSET_GC_PUMP_001', 'Port Arthur Crude Pump P-801', 'Pump', 'Transportation', 'Flowserve API 610', 'Flowserve', 8, 29.8688, -93.9400, NULL, '2017-04-15', 50000, 'BBL/day', 99, 'Active', '2024-01-01', TRUE),
(1009, 'ASSET_GC_TURB_001', 'Houston Power Turbine GT-901', 'Turbine', 'Production', 'Siemens SGT-800', 'Siemens', 9, 29.7363, -95.2671, NULL, '2019-07-22', 40, 'MW', 96, 'Active', '2024-01-01', TRUE),
(1010, 'ASSET_GC_COMP_001', 'Louisiana Platform Compressor C-1001', 'Compressor', 'Production', 'Solar Taurus 70', 'Solar Turbines', 10, 29.2588, -91.2067, NULL, '2018-12-05', 450, 'MMCF/day', 94, 'Active', '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_WAREHOUSE
-- ============================================================================
INSERT INTO DIM_WAREHOUSE (
    WAREHOUSE_KEY, WAREHOUSE_ID, WAREHOUSE_NAME, WAREHOUSE_TYPE, ADDRESS,
    SITE_KEY, LATITUDE, LONGITUDE, WAREHOUSE_LOCATION,
    TOTAL_CAPACITY_SQ_FT, CURRENT_UTILIZATION_PERCENT,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
(1, 'WH_HOUSTON_DC', 'Houston Distribution Center', 'Distribution Center', '12000 Clinton Dr, Houston, TX 77029', 13, 29.7604, -95.3698, NULL, 150000, 68.5, '2024-01-01', TRUE),
(2, 'WH_MIDLAND_FIELD', 'Midland Field Depot', 'Field Depot', '4500 W Loop 250 N, Midland, TX 79707', NULL, 32.0298, -102.1335, NULL, 25000, 75.2, '2024-01-01', TRUE),
(3, 'WH_OKLAHOMA_HUB', 'Oklahoma City Regional Hub', 'Regional Hub', '7800 S Council Rd, Oklahoma City, OK 73169', 14, 35.4676, -97.5164, NULL, 80000, 62.8, '2024-01-01', TRUE),
(4, 'WH_WILLISTON_FIELD', 'Williston Supply Hub', 'Field Depot', '3801 2nd Ave W, Williston, ND 58801', 15, 48.1467, -103.6201, NULL, 30000, 58.3, '2024-01-01', TRUE),
(5, 'WH_CORPUS_CHRISTI', 'Corpus Christi Warehouse', 'Distribution Center', '1200 Navigation Blvd, Corpus Christi, TX 78407', NULL, 27.7942, -97.3920, NULL, 45000, 71.5, '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_SKU (Critical spare parts)
-- ============================================================================
INSERT INTO DIM_SKU (
    SKU_KEY, SKU_ID, PART_NUMBER, PART_NAME, DESCRIPTION,
    PART_CATEGORY, PART_SUBCATEGORY, CRITICALITY,
    MANUFACTURER, UNIT_OF_MEASURE, WEIGHT_LBS,
    UNIT_COST_USD, LEAD_TIME_DAYS, REORDER_POINT, ECONOMIC_ORDER_QUANTITY,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
(1, 'SKU_COMP_ROTOR_001', 'CAT-3608-ROTOR', 'Compressor Rotor Assembly', 'Main rotor assembly for CAT 3608 compressor', 'Rotating Equipment', 'Compressor Parts', 'Critical', 'Caterpillar', 'EA', 850, 125000.00, 90, 1, 2, '2024-01-01', TRUE),
(2, 'SKU_COMP_SEAL_001', 'SEAL-DRY-001', 'Dry Gas Seal', 'Dry gas seal for reciprocating compressor', 'Rotating Equipment', 'Seals', 'Critical', 'John Crane', 'EA', 25, 15000.00, 45, 2, 4, '2024-01-01', TRUE),
(3, 'SKU_PUMP_IMP_001', 'FS-API610-IMP', 'Pump Impeller', 'Flowserve API 610 pump impeller', 'Rotating Equipment', 'Pump Parts', 'Critical', 'Flowserve', 'EA', 125, 22000.00, 60, 1, 3, '2024-01-01', TRUE),
(4, 'SKU_PUMP_SEAL_001', 'SEAL-MECH-001', 'Mechanical Seal', 'Mechanical seal for centrifugal pump', 'Rotating Equipment', 'Seals', 'Important', 'Flowserve', 'EA', 15, 8500.00, 30, 3, 6, '2024-01-01', TRUE),
(5, 'SKU_TURB_BLADE_001', 'GE-LM2500-BLADE', 'Turbine Blade Set', 'GE LM2500 turbine blade set', 'Rotating Equipment', 'Turbine Parts', 'Critical', 'General Electric', 'SET', 450, 285000.00, 120, 1, 1, '2024-01-01', TRUE),
(6, 'SKU_TURB_BEARING_001', 'BEAR-THRUST-001', 'Thrust Bearing', 'Heavy duty thrust bearing for gas turbine', 'Rotating Equipment', 'Bearings', 'Critical', 'SKF', 'EA', 200, 45000.00, 75, 2, 3, '2024-01-01', TRUE),
(7, 'SKU_VALVE_CTRL_001', 'FISHER-CV-001', 'Control Valve', 'Fisher control valve 4-inch', 'Valves', 'Control Valves', 'Important', 'Emerson', 'EA', 85, 12000.00, 45, 2, 4, '2024-01-01', TRUE),
(8, 'SKU_MOTOR_ELEC_001', 'MOTOR-460V-100HP', 'Electric Motor 100HP', '460V 100HP electric motor', 'Electrical', 'Motors', 'Important', 'ABB', 'EA', 650, 18000.00, 60, 1, 2, '2024-01-01', TRUE),
(9, 'SKU_FILTER_OIL_001', 'FILTER-LUBE-001', 'Lube Oil Filter', 'Lube oil filter cartridge', 'Rotating Equipment', 'Filters', 'Standard', 'Pall', 'EA', 8, 450.00, 14, 10, 20, '2024-01-01', TRUE),
(10, 'SKU_SENSOR_VIBE_001', 'SENSOR-VIB-001', 'Vibration Sensor', 'Vibration monitoring sensor', 'Instrumentation', 'Sensors', 'Important', 'Bently Nevada', 'EA', 5, 3500.00, 30, 3, 5, '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_BOM (Asset Type to SKU mappings)
-- ============================================================================
INSERT INTO DIM_BOM (
    BOM_KEY, ASSET_TYPE, SKU_KEY, REQUIRED_QUANTITY, CRITICALITY_LEVEL,
    MTBF_HOURS, TYPICAL_REPLACEMENT_INTERVAL_DAYS,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
-- Compressor BOMs
(1, 'Compressor', 1, 1, 'Critical', 35000, 730, '2024-01-01', TRUE),
(2, 'Compressor', 2, 2, 'Critical', 17500, 365, '2024-01-01', TRUE),
(3, 'Compressor', 9, 4, 'Medium', 2000, 90, '2024-01-01', TRUE),
(4, 'Compressor', 10, 2, 'High', 50000, 365, '2024-01-01', TRUE),

-- Pump BOMs
(5, 'Pump', 3, 1, 'Critical', 25000, 545, '2024-01-01', TRUE),
(6, 'Pump', 4, 1, 'Critical', 12000, 365, '2024-01-01', TRUE),
(7, 'Pump', 8, 1, 'High', 30000, 730, '2024-01-01', TRUE),
(8, 'Pump', 9, 2, 'Medium', 2000, 90, '2024-01-01', TRUE),
(9, 'Pump', 10, 1, 'High', 50000, 365, '2024-01-01', TRUE),

-- Turbine BOMs
(10, 'Turbine', 5, 1, 'Critical', 40000, 1095, '2024-01-01', TRUE),
(11, 'Turbine', 6, 2, 'Critical', 50000, 730, '2024-01-01', TRUE),
(12, 'Turbine', 9, 6, 'Medium', 2000, 60, '2024-01-01', TRUE),
(13, 'Turbine', 10, 4, 'High', 50000, 365, '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_FAILURE_TYPE
-- ============================================================================
INSERT INTO DIM_FAILURE_TYPE (
    FAILURE_TYPE_KEY, FAILURE_CODE, FAILURE_NAME, FAILURE_CATEGORY,
    DESCRIPTION, TYPICAL_CAUSES, IS_WEATHER_RELATED
) VALUES
(1, 'MECH_SEAL_FAIL', 'Seal Failure', 'Mechanical', 'Seal degradation or failure causing leaks', 'Wear, contamination, temperature extremes', TRUE),
(2, 'MECH_BEARING_FAIL', 'Bearing Failure', 'Mechanical', 'Bearing degradation causing vibration/noise', 'Wear, lubrication failure, contamination, cold weather', TRUE),
(3, 'MECH_ROTOR_DAMAGE', 'Rotor Damage', 'Mechanical', 'Damage to rotor assembly', 'Foreign object, imbalance, vibration', FALSE),
(4, 'MECH_IMPELLER_WEAR', 'Impeller Wear', 'Mechanical', 'Excessive wear on pump impeller', 'Cavitation, erosion, corrosion', FALSE),
(5, 'ELEC_MOTOR_FAIL', 'Motor Failure', 'Electrical', 'Electric motor winding failure', 'Overload, insulation breakdown, overheating', TRUE),
(6, 'ELEC_SENSOR_FAIL', 'Sensor Failure', 'Electrical', 'Instrumentation sensor malfunction', 'Environmental exposure, calibration drift', TRUE),
(7, 'INST_VALVE_STICK', 'Control Valve Sticking', 'Instrumentation', 'Control valve fails to respond', 'Contamination, actuator failure, freezing', TRUE),
(8, 'MECH_VIBRATION', 'Excessive Vibration', 'Mechanical', 'Abnormal vibration levels', 'Imbalance, misalignment, bearing wear', FALSE),
(9, 'LUBE_OIL_CONTAM', 'Lube Oil Contamination', 'Mechanical', 'Contamination of lubrication system', 'Water ingress, particulate, seal failure', TRUE),
(10, 'FREEZE_DAMAGE', 'Freeze Damage', 'Mechanical', 'Equipment damage from freezing', 'Extreme cold, inadequate winterization', TRUE);

-- ============================================================================
-- Load DIM_PRODUCTION_UNIT
-- ============================================================================
INSERT INTO DIM_PRODUCTION_UNIT (
    PRODUCTION_UNIT_KEY, PRODUCTION_UNIT_ID, UNIT_NAME, UNIT_TYPE,
    PRODUCT_FAMILY, SITE_KEY, NOMINAL_RATE_UNITS_PER_HOUR, CAPACITY_UNIT,
    LATITUDE, LONGITUDE, UNIT_LOCATION, UNIT_STATUS,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
(1, 'PROD_PM_001', 'Delaware Basin Well Pad A', 'Well', 'Crude Oil', 2, 625, 'BBL/day', 32.3513, -103.8758, NULL, 'Active', '2024-01-01', TRUE),
(2, 'PROD_PM_002', 'Midland Gas Processing Unit 1', 'Processing Plant', 'Natural Gas', 3, 20833, 'MCF/day', 31.8457, -102.3676, NULL, 'Active', '2024-01-01', TRUE),
(3, 'PROD_EF_001', 'Karnes County Well Pad B', 'Well', 'Crude Oil', 4, 500, 'BBL/day', 28.8846, -97.9003, NULL, 'Active', '2024-01-01', TRUE),
(4, 'PROD_EF_002', 'La Salle NGL Plant', 'Processing Plant', 'NGL', 5, 14583, 'MCF/day', 28.3472, -99.0848, NULL, 'Active', '2024-01-01', TRUE),
(5, 'PROD_BK_001', 'Williston Well Pad C', 'Well', 'Crude Oil', 6, 750, 'BBL/day', 48.1470, -103.6180, NULL, 'Active', '2024-01-01', TRUE),
(6, 'PROD_GC_001', 'Port Arthur Crude Pipeline', 'Pipeline', 'Crude Oil', 8, 2083, 'BBL/day', 29.8688, -93.9400, NULL, 'Active', '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_IMPACT_MODE
-- ============================================================================
INSERT INTO DIM_IMPACT_MODE (
    IMPACT_MODE_KEY, IMPACT_MODE_CODE, MODE_NAME, DESCRIPTION, OEE_CATEGORY, SEVERITY
) VALUES
(1, 'IMP_FULL_STOP', 'Full Stop', 'Complete production shutdown', 'Availability', 'Full Stop'),
(2, 'IMP_SPEED_LOSS', 'Speed Loss', 'Reduced production rate below nominal', 'Performance', 'Major'),
(3, 'IMP_MINOR_STOP', 'Minor Stop', 'Brief interruption under 5 minutes', 'Availability', 'Minor'),
(4, 'IMP_QUALITY_LOSS', 'Quality Loss', 'Production of off-spec product', 'Quality', 'Major'),
(5, 'IMP_STARTUP_LOSS', 'Startup Loss', 'Reduced rate during startup/ramp', 'Performance', 'Minor');

-- ============================================================================
-- Load BRG_PRODUCTION_UNIT_ASSET
-- ============================================================================
INSERT INTO BRG_PRODUCTION_UNIT_ASSET (
    BRIDGE_KEY, PRODUCTION_UNIT_KEY, ASSET_KEY, CONTRIBUTION_FACTOR,
    BOTTLENECK_FLAG, REDUNDANCY_TYPE, CRITICALITY_SCORE,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
(1, 1, 1002, 0.85, TRUE, 'None', 95, '2024-01-01', TRUE),
(2, 2, 1001, 1.00, TRUE, 'None', 98, '2024-01-01', TRUE),
(3, 2, 1003, 0.75, FALSE, 'N+1', 90, '2024-01-01', TRUE),
(4, 3, 1004, 0.90, TRUE, 'None', 92, '2024-01-01', TRUE),
(5, 4, 1005, 0.95, TRUE, 'None', 95, '2024-01-01', TRUE),
(6, 5, 1006, 0.88, TRUE, 'None', 93, '2024-01-01', TRUE),
(7, 5, 1007, 0.82, FALSE, 'Parallel', 85, '2024-01-01', TRUE),
(8, 6, 1008, 1.00, TRUE, 'None', 99, '2024-01-01', TRUE);

