-- ============================================================================
-- Load Scenario 01a Dimension Data (Project Risk Assessment)
-- ============================================================================
-- Purpose: Insert sample data for project risk scenario
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Load DIM_DELAY_TYPE
-- ============================================================================
INSERT INTO DIM_DELAY_TYPE (
    DELAY_TYPE_KEY, DELAY_CODE, DELAY_CATEGORY, DELAY_SUBCATEGORY, 
    ROOT_CAUSE_DETAIL, IS_WEATHER_RELATED
) VALUES
(1, 'WEATHER_RAIN', 'Weather', 'Precipitation', 'Heavy rainfall preventing site work', TRUE),
(2, 'WEATHER_WIND', 'Weather', 'Wind', 'High winds exceeding safety limits', TRUE),
(3, 'WEATHER_FREEZE', 'Weather', 'Temperature', 'Freezing temperatures stopping concrete work', TRUE),
(4, 'WEATHER_HEAT', 'Weather', 'Temperature', 'Extreme heat limiting outdoor work hours', TRUE),
(5, 'WEATHER_STORM', 'Weather', 'Severe Weather', 'Hurricane/tornado forcing site evacuation', TRUE),
(6, 'WEATHER_LIGHTNING', 'Weather', 'Lightning', 'Lightning risk halting elevated work', TRUE),
(7, 'WEATHER_FLOOD', 'Weather', 'Flooding', 'Site flooding from excessive rain', TRUE),
(8, 'LABOR_SHORTAGE', 'Labor', 'Availability', 'Insufficient skilled labor available', FALSE),
(9, 'LABOR_STRIKE', 'Labor', 'Industrial Action', 'Work stoppage due to labor dispute', FALSE),
(10, 'MATERIAL_LATE', 'Material', 'Delivery', 'Late delivery of critical materials', FALSE),
(11, 'MATERIAL_DEFECT', 'Material', 'Quality', 'Defective materials requiring replacement', FALSE),
(12, 'EQUIPMENT_FAILURE', 'Equipment', 'Breakdown', 'Equipment malfunction or breakdown', FALSE),
(13, 'EQUIPMENT_UNAVAIL', 'Equipment', 'Availability', 'Required equipment not available', FALSE),
(14, 'PERMIT_DELAY', 'Permit', 'Regulatory', 'Delay in obtaining required permits', FALSE),
(15, 'DESIGN_CHANGE', 'Design', 'Engineering', 'Engineering changes requiring rework', FALSE);

-- ============================================================================
-- Load DIM_PROJECT
-- ============================================================================
INSERT INTO DIM_PROJECT (
    PROJECT_KEY, PROJECT_ID, PROJECT_NAME, PROJECT_TYPE, SITE_KEY,
    PROJECT_MANAGER, PORTFOLIO, PLANNED_START_DATE, PLANNED_END_DATE,
    BASELINE_DURATION_DAYS, APPROVED_BUDGET_USD, BUDGET_CATEGORY,
    PROJECT_STATUS, PLANNED_CAPACITY, CAPACITY_UNIT, IN_SERVICE_DATE,
    EFFECTIVE_DATE, IS_CURRENT
) VALUES
-- Permian Basin Projects
(1, 'PROJ_PERMIAN_DRILL_001', 'Midland Basin Horizontal Wells Phase 1', 'Drilling', 1, 'Sarah Chen', 'Permian Basin', '2024-03-01', '2024-12-31', 305, 45000000.00, 'CapEx', 'Active', 15000, 'BOE/day', '2025-01-15', '2024-01-01', TRUE),
(2, 'PROJ_PERMIAN_PIPE_002', 'Delaware to Midland Pipeline Extension', 'Pipeline', 2, 'Michael Torres', 'Permian Basin', '2024-04-15', '2025-06-30', 441, 125000000.00, 'CapEx', 'Active', 250000, 'BBL/day', '2025-07-01', '2024-01-01', TRUE),
(3, 'PROJ_PERMIAN_COMP_003', 'Odessa Compressor Station Upgrade', 'Facility Construction', 3, 'Jennifer Lopez', 'Permian Basin', '2024-06-01', '2025-03-31', 304, 32000000.00, 'CapEx', 'Active', 500, 'MMCF/day', '2025-04-15', '2024-01-01', TRUE),

-- Eagle Ford Projects  
(4, 'PROJ_EAGLE_DRILL_001', 'Karnes County Development Wells', 'Drilling', 4, 'Robert Williams', 'Eagle Ford Shale', '2024-02-01', '2024-11-30', 303, 38000000.00, 'CapEx', 'Active', 12000, 'BOE/day', '2024-12-15', '2024-01-01', TRUE),
(5, 'PROJ_EAGLE_FACILITY_002', 'La Salle Gas Processing Expansion', 'Facility Construction', 5, 'Amanda Martinez', 'Eagle Ford Shale', '2024-05-01', '2025-08-31', 487, 95000000.00, 'CapEx', 'Active', 350, 'MMCF/day', '2025-09-15', '2024-01-01', TRUE),

-- Bakken Projects
(6, 'PROJ_BAKKEN_DRILL_001', 'Williston Basin Multi-Well Pad', 'Drilling', 6, 'David Anderson', 'Bakken Formation', '2024-03-15', '2024-12-15', 275, 52000000.00, 'CapEx', 'Active', 18000, 'BOE/day', '2025-01-01', '2024-01-01', TRUE),
(7, 'PROJ_BAKKEN_WELL_002', 'McKenzie County Well Completions', 'Well Completion', 7, 'Lisa Thompson', 'Bakken Formation', '2024-07-01', '2025-02-28', 242, 28000000.00, 'CapEx', 'Active', 8500, 'BOE/day', '2025-03-15', '2024-01-01', TRUE),

-- Gulf Coast Projects
(8, 'PROJ_GULF_REFINERY_001', 'Port Arthur Hydrocracker Unit', 'Facility Construction', 8, 'James Wilson', 'Gulf Coast', '2024-01-15', '2025-12-31', 716, 285000000.00, 'CapEx', 'Active', 75000, 'BBL/day', '2026-02-01', '2024-01-01', TRUE),
(9, 'PROJ_GULF_TERMINAL_002', 'Houston Terminal Storage Expansion', 'Facility Construction', 9, 'Patricia Garcia', 'Gulf Coast', '2024-04-01', '2025-05-31', 425, 65000000.00, 'CapEx', 'Active', 500000, 'BBL capacity', '2025-06-15', '2024-01-01', TRUE),
(10, 'PROJ_GULF_PLATFORM_003', 'Louisiana Offshore Platform Upgrade', 'Facility Construction', 10, 'Christopher Lee', 'Gulf Coast', '2024-08-01', '2025-10-31', 456, 175000000.00, 'CapEx', 'Active', 25000, 'BOE/day', '2025-11-15', '2024-01-01', TRUE);

-- ============================================================================
-- Load DIM_ACTIVITY (Critical path activities for each project)
-- ============================================================================
INSERT INTO DIM_ACTIVITY (
    ACTIVITY_KEY, ACTIVITY_ID, ACTIVITY_NAME, PROJECT_KEY, ACTIVITY_TYPE,
    WBS_CODE, WBS_LEVEL, IS_CRITICAL_PATH, FLOAT_DAYS, FREE_FLOAT_DAYS,
    PLANNED_START_DATE, PLANNED_END_DATE, PLANNED_DURATION_DAYS,
    WEATHER_SENSITIVE, WEATHER_CONSTRAINTS, EFFECTIVE_DATE, IS_CURRENT
) VALUES
-- Project 1: Midland Basin Horizontal Wells
(1, 'ACT_P1_010', 'Site Preparation and Pad Construction', 1, 'Site Preparation', '1.1', 2, TRUE, 0, 0, '2024-03-01', '2024-04-15', 45, TRUE, 'No heavy rain, wind < 25mph', '2024-01-01', TRUE),
(2, 'ACT_P1_020', 'Rig Mobilization', 1, 'Mobilization', '1.2', 2, TRUE, 0, 0, '2024-04-16', '2024-04-30', 14, TRUE, 'Wind < 30mph', '2024-01-01', TRUE),
(3, 'ACT_P1_030', 'Well 1 Drilling Operations', 1, 'Drilling', '2.1', 2, TRUE, 0, 0, '2024-05-01', '2024-06-15', 45, TRUE, 'Wind < 35mph, no lightning', '2024-01-01', TRUE),
(4, 'ACT_P1_040', 'Well 1 Casing and Cementing', 1, 'Drilling', '2.2', 2, TRUE, 0, 0, '2024-06-16', '2024-07-10', 24, TRUE, 'No extreme heat, temp < 105F', '2024-01-01', TRUE),
(5, 'ACT_P1_050', 'Well 1 Completion and Perforation', 1, 'Well Completion', '2.3', 2, TRUE, 0, 0, '2024-07-11', '2024-08-15', 35, TRUE, 'Wind < 30mph', '2024-01-01', TRUE),
(6, 'ACT_P1_060', 'Well 2-4 Drilling (Sequential)', 1, 'Drilling', '2.4', 2, TRUE, 0, 0, '2024-08-16', '2024-11-30', 106, TRUE, 'Wind < 35mph, no lightning', '2024-01-01', TRUE),
(7, 'ACT_P1_070', 'Production Facility Installation', 1, 'Installation', '3.1', 2, TRUE, 0, 0, '2024-09-01', '2024-11-15', 75, TRUE, 'No heavy rain, wind < 25mph', '2024-01-01', TRUE),
(8, 'ACT_P1_080', 'Pipeline Tie-In and Commissioning', 1, 'Commissioning', '3.2', 2, TRUE, 0, 0, '2024-11-16', '2024-12-31', 46, TRUE, 'No freezing temps', '2024-01-01', TRUE),

-- Project 2: Pipeline Extension
(9, 'ACT_P2_010', 'Environmental Survey and Permits', 2, 'Engineering', '1.1', 2, TRUE, 0, 0, '2024-04-15', '2024-05-31', 46, FALSE, NULL, '2024-01-01', TRUE),
(10, 'ACT_P2_020', 'Right-of-Way Clearing', 2, 'Site Preparation', '1.2', 2, TRUE, 0, 0, '2024-06-01', '2024-07-31', 60, TRUE, 'No extreme heat, temp < 105F', '2024-01-01', TRUE),
(11, 'ACT_P2_030', 'Trench Excavation Segment 1', 2, 'Installation', '2.1', 2, TRUE, 0, 0, '2024-08-01', '2024-10-15', 75, TRUE, 'No heavy rain, ground not saturated', '2024-01-01', TRUE),
(12, 'ACT_P2_040', 'Pipeline Welding and Laying Segment 1', 2, 'Installation', '2.2', 2, TRUE, 0, 0, '2024-10-16', '2024-12-31', 76, TRUE, 'Wind < 25mph, no rain during welding', '2024-01-01', TRUE),
(13, 'ACT_P2_050', 'Trench Excavation Segment 2', 2, 'Installation', '2.3', 2, TRUE, 0, 0, '2025-01-01', '2025-03-15', 73, TRUE, 'No heavy rain, no freezing', '2024-01-01', TRUE),
(14, 'ACT_P2_060', 'Pipeline Welding and Laying Segment 2', 2, 'Installation', '2.4', 2, TRUE, 0, 0, '2025-03-16', '2025-05-31', 76, TRUE, 'Wind < 25mph', '2024-01-01', TRUE),
(15, 'ACT_P2_070', 'Hydrostatic Testing', 2, 'Commissioning', '3.1', 2, TRUE, 0, 0, '2025-06-01', '2025-06-15', 14, FALSE, NULL, '2024-01-01', TRUE),
(16, 'ACT_P2_080', 'Final Commissioning', 2, 'Commissioning', '3.2', 2, TRUE, 0, 0, '2025-06-16', '2025-06-30', 14, FALSE, NULL, '2024-01-01', TRUE),

-- Project 4: Karnes County Development Wells
(17, 'ACT_P4_010', 'Pad Site Earthwork', 4, 'Site Preparation', '1.1', 2, TRUE, 0, 0, '2024-02-01', '2024-03-15', 43, TRUE, 'No heavy rain', '2024-01-01', TRUE),
(18, 'ACT_P4_020', 'Drilling Rig Setup', 4, 'Mobilization', '1.2', 2, TRUE, 0, 0, '2024-03-16', '2024-03-30', 14, TRUE, 'Wind < 30mph', '2024-01-01', TRUE),
(19, 'ACT_P4_030', 'Well 1-3 Drilling', 4, 'Drilling', '2.1', 2, TRUE, 0, 0, '2024-03-31', '2024-07-15', 107, TRUE, 'No lightning, wind < 35mph', '2024-01-01', TRUE),
(20, 'ACT_P4_040', 'Well Completions', 4, 'Well Completion', '2.2', 2, TRUE, 0, 0, '2024-07-16', '2024-10-15', 91, TRUE, 'Wind < 30mph', '2024-01-01', TRUE),
(21, 'ACT_P4_050', 'Surface Facilities Installation', 4, 'Installation', '3.1', 2, TRUE, 0, 0, '2024-08-01', '2024-10-31', 91, TRUE, 'No heavy rain, wind < 25mph', '2024-01-01', TRUE),
(22, 'ACT_P4_060', 'Flow Testing and Optimization', 4, 'Commissioning', '3.2', 2, TRUE, 0, 0, '2024-11-01', '2024-11-30', 29, FALSE, NULL, '2024-01-01', TRUE),

-- Project 8: Port Arthur Refinery
(23, 'ACT_P8_010', 'Engineering and Design Finalization', 8, 'Engineering', '1.1', 2, TRUE, 0, 0, '2024-01-15', '2024-04-30', 106, FALSE, NULL, '2024-01-01', TRUE),
(24, 'ACT_P8_020', 'Foundation Excavation', 8, 'Site Preparation', '2.1', 2, TRUE, 0, 0, '2024-05-01', '2024-06-30', 60, TRUE, 'No flooding, no heavy rain', '2024-01-01', TRUE),
(25, 'ACT_P8_030', 'Foundation Concrete Pour', 8, 'Installation', '2.2', 2, TRUE, 0, 0, '2024-07-01', '2024-08-31', 61, TRUE, 'Temp between 40-90F, no rain 24hr after pour', '2024-01-01', TRUE),
(26, 'ACT_P8_040', 'Structural Steel Erection', 8, 'Installation', '3.1', 2, TRUE, 0, 0, '2024-09-01', '2024-12-31', 121, TRUE, 'Wind < 25mph, no lightning', '2024-01-01', TRUE),
(27, 'ACT_P8_050', 'Equipment Installation Phase 1', 8, 'Installation', '3.2', 2, TRUE, 0, 0, '2025-01-01', '2025-05-31', 150, TRUE, 'Wind < 20mph for crane ops', '2024-01-01', TRUE),
(28, 'ACT_P8_060', 'Piping and Instrumentation', 8, 'Installation', '3.3', 2, TRUE, 0, 0, '2025-06-01', '2025-10-31', 152, TRUE, 'Wind < 25mph for elevated work', '2024-01-01', TRUE),
(29, 'ACT_P8_070', 'Electrical and Controls Integration', 8, 'Installation', '4.1', 2, TRUE, 0, 0, '2025-11-01', '2025-12-15', 44, FALSE, NULL, '2024-01-01', TRUE),
(30, 'ACT_P8_080', 'Pre-Commissioning and Start-Up', 8, 'Commissioning', '5.1', 2, TRUE, 0, 0, '2025-12-16', '2025-12-31', 15, FALSE, NULL, '2024-01-01', TRUE);

