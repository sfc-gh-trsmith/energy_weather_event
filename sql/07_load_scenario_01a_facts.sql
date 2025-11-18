-- ============================================================================
-- Load Scenario 01a Fact Data (Project Risk Assessment)
-- ============================================================================
-- Purpose: Generate activity snapshots and historical delay events
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

-- ============================================================================
-- Generate FCT_PROJECT_ACTIVITY_SNAPSHOT (Weekly snapshots for all activities)
-- ============================================================================
INSERT INTO FCT_PROJECT_ACTIVITY_SNAPSHOT (
    SNAPSHOT_KEY, PROJECT_KEY, ACTIVITY_KEY, SNAPSHOT_TIME_KEY,
    ACTUAL_START_DATE, ACTUAL_END_DATE, FORECAST_START_DATE, FORECAST_END_DATE,
    ACTUAL_DURATION_DAYS, REMAINING_DURATION_DAYS, PERCENT_COMPLETE,
    SCHEDULE_VARIANCE_DAYS, BUDGETED_COST_USD, ACTUAL_COST_USD,
    EARNED_VALUE_USD, COST_VARIANCE_USD, COST_COMMITMENT_USD,
    SPI, CPI, ACTIVITY_STATUS, SNAPSHOT_TIMESTAMP
)
WITH activity_weeks AS (
    SELECT
        a.ACTIVITY_KEY,
        a.PROJECT_KEY,
        a.PLANNED_START_DATE,
        a.PLANNED_END_DATE,
        a.PLANNED_DURATION_DAYS,
        t.TIME_KEY,
        t.FULL_DATE,
        -- Calculate progress based on planned schedule
        CASE 
            WHEN t.FULL_DATE < a.PLANNED_START_DATE THEN 0
            WHEN t.FULL_DATE > a.PLANNED_END_DATE THEN 100
            ELSE (DATEDIFF(day, a.PLANNED_START_DATE, t.FULL_DATE)::FLOAT / a.PLANNED_DURATION_DAYS::FLOAT) * 100
        END AS CALC_PERCENT_COMPLETE,
        -- Add some random variance
        UNIFORM(-5, 10, RANDOM()) AS SCHEDULE_VAR_DAYS,
        UNIFORM(-0.1, 0.15, RANDOM()) AS COST_VAR_PERCENT
    FROM DIM_ACTIVITY a
    JOIN DIM_TIME t ON t.FULL_DATE BETWEEN DATEADD(day, -7, a.PLANNED_START_DATE) AND DATEADD(day, 14, a.PLANNED_END_DATE)
    WHERE a.IS_CURRENT = TRUE
      AND DAYOFWEEK(t.FULL_DATE) = 1 -- Monday snapshots
)
SELECT
    ROW_NUMBER() OVER (ORDER BY PROJECT_KEY, ACTIVITY_KEY, TIME_KEY) AS SNAPSHOT_KEY,
    PROJECT_KEY,
    ACTIVITY_KEY,
    TIME_KEY AS SNAPSHOT_TIME_KEY,
    -- Actual dates
    CASE WHEN CALC_PERCENT_COMPLETE > 0 THEN PLANNED_START_DATE ELSE NULL END AS ACTUAL_START_DATE,
    CASE WHEN CALC_PERCENT_COMPLETE >= 100 THEN PLANNED_END_DATE + SCHEDULE_VAR_DAYS ELSE NULL END AS ACTUAL_END_DATE,
    -- Forecast dates
    PLANNED_START_DATE + SCHEDULE_VAR_DAYS AS FORECAST_START_DATE,
    PLANNED_END_DATE + SCHEDULE_VAR_DAYS AS FORECAST_END_DATE,
    -- Durations
    CASE WHEN CALC_PERCENT_COMPLETE >= 100 THEN PLANNED_DURATION_DAYS + SCHEDULE_VAR_DAYS ELSE NULL END AS ACTUAL_DURATION_DAYS,
    CASE 
        WHEN CALC_PERCENT_COMPLETE >= 100 THEN 0
        ELSE GREATEST(0, PLANNED_DURATION_DAYS * (1 - CALC_PERCENT_COMPLETE/100))
    END AS REMAINING_DURATION_DAYS,
    LEAST(100, GREATEST(0, CALC_PERCENT_COMPLETE)) AS PERCENT_COMPLETE,
    SCHEDULE_VAR_DAYS AS SCHEDULE_VARIANCE_DAYS,
    -- Cost metrics (derive from activity duration * daily rate)
    (PLANNED_DURATION_DAYS * 50000) AS BUDGETED_COST_USD,
    (PLANNED_DURATION_DAYS * 50000 * (CALC_PERCENT_COMPLETE/100) * (1 + COST_VAR_PERCENT)) AS ACTUAL_COST_USD,
    (PLANNED_DURATION_DAYS * 50000 * (CALC_PERCENT_COMPLETE/100)) AS EARNED_VALUE_USD,
    (PLANNED_DURATION_DAYS * 50000 * (CALC_PERCENT_COMPLETE/100) * COST_VAR_PERCENT * -1) AS COST_VARIANCE_USD,
    (PLANNED_DURATION_DAYS * 50000) AS COST_COMMITMENT_USD,
    -- Performance indices
    CASE 
        WHEN FULL_DATE < PLANNED_START_DATE THEN 1.0
        ELSE CALC_PERCENT_COMPLETE / GREATEST(1, (DATEDIFF(day, PLANNED_START_DATE, FULL_DATE)::FLOAT / PLANNED_DURATION_DAYS::FLOAT) * 100)
    END AS SPI,
    CASE 
        WHEN CALC_PERCENT_COMPLETE = 0 THEN 1.0
        ELSE 1.0 / (1 + ABS(COST_VAR_PERCENT))
    END AS CPI,
    -- Status
    CASE 
        WHEN CALC_PERCENT_COMPLETE = 0 THEN 'Not Started'
        WHEN CALC_PERCENT_COMPLETE >= 100 THEN 'Complete'
        WHEN CALC_PERCENT_COMPLETE > 0 THEN 'In Progress'
        ELSE 'Not Started'
    END AS ACTIVITY_STATUS,
    FULL_DATE::TIMESTAMP_NTZ AS SNAPSHOT_TIMESTAMP
FROM activity_weeks;

-- ============================================================================
-- Generate FCT_PROJECT_DELAY_EVENT (Historical weather-related delays)
-- ============================================================================
INSERT INTO FCT_PROJECT_DELAY_EVENT (
    DELAY_EVENT_KEY, PROJECT_KEY, ACTIVITY_KEY, DELAY_TYPE_KEY, EVENT_TIME_KEY,
    DELAY_START_DATE, DELAY_END_DATE, DELAY_DURATION_DAYS, DELAY_COST_USD,
    WEATHER_SEVERITY_AT_EVENT, TEMPERATURE_C_AT_EVENT, PRECIPITATION_MM_AT_EVENT,
    WIND_SPEED_KPH_AT_EVENT, CRITICAL_PATH_IMPACT_DAYS, PROJECT_COMPLETION_IMPACT_DAYS,
    DELAY_DESCRIPTION, ROOT_CAUSE_NOTES, MITIGATION_ACTIONS, EVENT_RECORDED_AT
)
VALUES
-- Hurricane delay - Gulf Coast project
(1, 8, 24, 7, 20240915, '2024-09-15', '2024-09-19', 4, 850000, 95, 28, 150, 120, 4, 4, 
 'Site flooded due to Hurricane - Foundation excavation halted', 
 'Hurricane forced evacuation of all personnel. Site experienced 150mm of rain causing flooding in excavation area. Required pumping and re-grading before work could resume.',
 'Deployed additional pumps, brought in dewatering equipment, extended work hours post-storm to recover schedule',
 '2024-09-19 16:00:00'),

(2, 8, 25, 2, 20240915, '2024-09-16', '2024-09-18', 2, 425000, 95, 28, 150, 120, 0, 0,
 'High winds prevented concrete pour operations',
 'Wind speeds exceeded 70mph during Hurricane event. Safety protocols prevented crane operations and concrete pours.',
 'Rescheduled concrete pour for following week, no critical path impact as foundation activity had float',
 '2024-09-18 10:00:00'),

-- Winter freeze - Permian Basin
(3, 1, 1, 3, 20240210, '2024-02-10', '2024-02-14', 4, 320000, 85, -15, 8, 55, 4, 4,
 'Extreme cold prevented site preparation work',
 'Temperatures dropped to -15C with wind chill to -25C. Equipment failures, frozen ground prevented earthwork.',
 'Used ground heaters and insulated equipment. Extended work hours after thaw to recover schedule.',
 '2024-02-14 14:00:00'),

(4, 3, 7, 3, 20240211, '2024-02-11', '2024-02-13', 2, 180000, 85, -15, 5, 55, 0, 0,
 'Equipment freeze-offs at compressor site',
 'Multiple equipment failures due to extreme cold. Diesel gelling, hydraulic failures.',
 'Switched to winter-grade fluids, added equipment heaters',
 '2024-02-13 09:00:00'),

-- Thunderstorms - Eagle Ford
(5, 4, 17, 1, 20240620, '2024-06-20', '2024-06-22', 2, 220000, 75, 32, 80, 65, 2, 2,
 'Heavy rain prevented pad earthwork',
 'Site became saturated with 80mm of rain over 2 days. Earthmoving equipment unable to operate safely.',
 'Waited for site to dry, brought in additional equipment to expedite work',
 '2024-06-22 12:00:00'),

(6, 4, 19, 6, 20240621, '2024-06-21', '2024-06-21', 0.5, 85000, 75, 32, 80, 65, 0, 0,
 'Lightning halted drilling operations',
 'Active lightning within 5-mile radius. Safety protocols required rig shutdown.',
 'No mitigation possible - safety requirement. Resumed operations after storm passed.',
 '2024-06-21 18:00:00'),

-- Blizzard - Bakken
(7, 6, 14, 5, 20250118, '2025-01-18', '2025-01-22', 4, 950000, 90, -25, 40, 75, 4, 4,
 'Blizzard forced site evacuation and complete shutdown',
 'Severe blizzard with -25C temps and 75kph winds. Zero visibility, all personnel evacuated for safety.',
 'Pre-positioned supplies, ensured equipment winterization, extended hours post-storm',
 '2025-01-22 15:00:00'),

-- Additional weather delays across different projects
(8, 2, 10, 4, 20240715, '2024-07-15', '2024-07-17', 2, 180000, 65, 42, 0, 28, 0, 0,
 'Extreme heat stopped outdoor work during peak hours',
 'Temperatures exceeded 42C. OSHA heat stress protocols limited work to early morning/evening.',
 'Adjusted work schedule to night shifts, provided additional hydration stations',
 '2024-07-17 10:00:00'),

(9, 2, 11, 1, 20241005, '2024-10-05', '2024-10-07', 2, 280000, 70, 25, 65, 45, 2, 2,
 'Heavy rain delayed trench excavation',
 'Sustained heavy rainfall over 48 hours. Trenches filled with water, unstable conditions.',
 'Deployed pumps, installed temporary drainage, waited for ground to stabilize',
 '2024-10-07 14:00:00'),

(10, 9, 21, 2, 20240820, '2024-08-20', '2024-08-21', 1, 125000, 60, 35, 15, 52, 0, 0,
 'High winds prevented crane operations',
 'Wind speeds 50+ kph exceeded crane operational limits for lifting heavy equipment.',
 'Rescheduled lifts to next day with favorable conditions',
 '2024-08-21 08:00:00');

-- Add weather data correlation to delays
MERGE INTO FCT_PROJECT_DELAY_EVENT de
USING (
    SELECT 
        de.DELAY_EVENT_KEY,
        wf.WEATHER_SEVERITY_SCORE,
        wf.TEMPERATURE_C,
        wf.PRECIPITATION_MM,
        wf.WIND_SPEED_KPH
    FROM FCT_PROJECT_DELAY_EVENT de
    JOIN DIM_PROJECT p ON p.PROJECT_KEY = de.PROJECT_KEY
    JOIN FCT_WEATHER_FORECAST wf ON wf.SITE_KEY = p.SITE_KEY AND wf.TIME_KEY = de.EVENT_TIME_KEY
    WHERE de.WEATHER_SEVERITY_AT_EVENT IS NULL
) src
ON de.DELAY_EVENT_KEY = src.DELAY_EVENT_KEY
WHEN MATCHED THEN UPDATE SET
    de.WEATHER_SEVERITY_AT_EVENT = src.WEATHER_SEVERITY_SCORE,
    de.TEMPERATURE_C_AT_EVENT = src.TEMPERATURE_C,
    de.PRECIPITATION_MM_AT_EVENT = src.PRECIPITATION_MM,
    de.WIND_SPEED_KPH_AT_EVENT = src.WIND_SPEED_KPH;

