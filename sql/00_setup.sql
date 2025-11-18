-- ============================================================================
-- Setup Script: Database, Schema, Role, Warehouse
-- ============================================================================
-- Purpose: Create core Snowflake objects for Energy Weather Event demo
-- ============================================================================

-- Use ACCOUNTADMIN role for initial setup
USE ROLE ACCOUNTADMIN;

-- Create database
CREATE DATABASE IF NOT EXISTS ENERGY_WEATHER_EVENT;

-- Create role
CREATE ROLE IF NOT EXISTS ENERGY_WEATHER_EVENT_ROLE;

-- Grant database privileges to role
GRANT USAGE ON DATABASE ENERGY_WEATHER_EVENT TO ROLE ENERGY_WEATHER_EVENT_ROLE;
GRANT CREATE SCHEMA ON DATABASE ENERGY_WEATHER_EVENT TO ROLE ENERGY_WEATHER_EVENT_ROLE;

-- Create warehouse
CREATE WAREHOUSE IF NOT EXISTS ENERGY_WEATHER_EVENT_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Energy Weather Event demos';

-- Grant warehouse privileges to role
GRANT USAGE ON WAREHOUSE ENERGY_WEATHER_EVENT_WH TO ROLE ENERGY_WEATHER_EVENT_ROLE;

-- Create schema
CREATE SCHEMA IF NOT EXISTS ENERGY_WEATHER_EVENT.ENERGY_DATA
    COMMENT = 'Unified schema for all energy weather event scenarios';

-- Grant schema privileges to role
GRANT USAGE ON SCHEMA ENERGY_WEATHER_EVENT.ENERGY_DATA TO ROLE ENERGY_WEATHER_EVENT_ROLE;
GRANT CREATE TABLE ON SCHEMA ENERGY_WEATHER_EVENT.ENERGY_DATA TO ROLE ENERGY_WEATHER_EVENT_ROLE;
GRANT CREATE VIEW ON SCHEMA ENERGY_WEATHER_EVENT.ENERGY_DATA TO ROLE ENERGY_WEATHER_EVENT_ROLE;

-- Use context
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
USE WAREHOUSE ENERGY_WEATHER_EVENT_WH;

