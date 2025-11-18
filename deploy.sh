#!/bin/bash

# ============================================================================
# deploy.sh - Deploy Energy Weather Event Demo
# ============================================================================
# Purpose: Create all Snowflake objects and load sample data
# Usage: ./deploy.sh
# ============================================================================

set -e  # Exit on error

echo "============================================================================"
echo "Energy Weather Event Demo - Deployment Script"
echo "============================================================================"
echo ""

# Configuration
CONNECTION="demo"
SQL_DIR="./sql"

# Check if snow CLI is available
if ! command -v snow &> /dev/null; then
    echo "ERROR: Snowflake CLI (snow) is not installed or not in PATH"
    echo "Please install using: pip install snowflake-cli-labs"
    exit 1
fi

# Check if connection exists
echo "Checking Snowflake connection '$CONNECTION'..."
if ! snow connection test --connection "$CONNECTION" &> /dev/null; then
    echo "ERROR: Connection '$CONNECTION' not found or invalid"
    echo "Please configure using: snow connection add"
    exit 1
fi
echo "✓ Connection validated"
echo ""

# Function to execute SQL file
execute_sql() {
    local sql_file=$1
    local description=$2
    
    echo "Executing: $description"
    echo "  File: $sql_file"
    
    if [ ! -f "$sql_file" ]; then
        echo "  ERROR: File not found: $sql_file"
        exit 1
    fi
    
    if snow sql --connection "$CONNECTION" --filename "$sql_file" > /dev/null 2>&1; then
        echo "  ✓ Success"
    else
        echo "  ✗ Failed"
        exit 1
    fi
    echo ""
}

# Step 1: Setup database and schema
echo "============================================================================"
echo "STEP 1: Setup Database, Schema, Role, and Warehouse"
echo "============================================================================"
execute_sql "$SQL_DIR/00_setup.sql" "Create database, schema, role, warehouse"

# Step 2: Create shared dimensions
echo "============================================================================"
echo "STEP 2: Create Shared Dimension Tables"
echo "============================================================================"
execute_sql "$SQL_DIR/01_shared_dimensions.sql" "Create shared dimension tables"

# Step 3: Create shared facts
echo "============================================================================"
echo "STEP 3: Create Shared Fact Tables"
echo "============================================================================"
execute_sql "$SQL_DIR/02_shared_facts.sql" "Create shared fact tables"

# Step 4: Create scenario 01a tables
echo "============================================================================"
echo "STEP 4: Create Scenario 01a Tables (Project Risk)"
echo "============================================================================"
execute_sql "$SQL_DIR/03_scenario_01a_project_risk.sql" "Create project risk tables"

# Step 5: Load shared dimension data
echo "============================================================================"
echo "STEP 5: Load Shared Dimension Data"
echo "============================================================================"
execute_sql "$SQL_DIR/04_load_shared_dimensions.sql" "Load time, sites, weather models"

# Step 6: Load scenario 01a dimension data
echo "============================================================================"
echo "STEP 6: Load Scenario 01a Dimension Data"
echo "============================================================================"
execute_sql "$SQL_DIR/05_load_scenario_01a_dimensions.sql" "Load projects, activities, delay types"

# Step 7: Load weather forecast data
echo "============================================================================"
echo "STEP 7: Load Weather Forecast Data"
echo "============================================================================"
echo "NOTE: This may take 2-3 minutes to generate weather data for all sites..."
execute_sql "$SQL_DIR/06_load_weather_facts.sql" "Generate weather forecast data"

# Step 8: Load scenario 01a fact data
echo "============================================================================"
echo "STEP 8: Load Scenario 01a Fact Data"
echo "============================================================================"
echo "NOTE: This may take 1-2 minutes to generate activity snapshots..."
execute_sql "$SQL_DIR/07_load_scenario_01a_facts.sql" "Generate activity snapshots and delays"

# Step 9: Create scenario 02a tables
echo "============================================================================"
echo "STEP 9: Create Scenario 02a Tables (Asset & Inventory)"
echo "============================================================================"
execute_sql "$SQL_DIR/08_scenario_02a_asset_inventory.sql" "Create asset and inventory tables"

# Step 10: Load scenario 02a dimension data
echo "============================================================================"
echo "STEP 10: Load Scenario 02a Dimension Data"
echo "============================================================================"
execute_sql "$SQL_DIR/10_load_scenario_02a_dimensions.sql" "Load assets, warehouses, SKUs, BOM"

# Step 11: Load scenario 02a fact data
echo "============================================================================"
echo "STEP 11: Load Scenario 02a Fact Data"
echo "============================================================================"
echo "NOTE: This may take 2-3 minutes to generate telemetry and inventory data..."
execute_sql "$SQL_DIR/11_load_scenario_02a_facts.sql" "Generate inventory, maintenance, telemetry"

# Step 12: Create scenario 03 tables
echo "============================================================================"
echo "STEP 12: Create Scenario 03 Tables (Hedge Mismatch)"
echo "============================================================================"
execute_sql "$SQL_DIR/09_scenario_03_hedge_mismatch.sql" "Create trading and hedge tables"

# Step 13: Load scenario 03 dimension data
echo "============================================================================"
echo "STEP 13: Load Scenario 03 Dimension Data"
echo "============================================================================"
execute_sql "$SQL_DIR/12_load_scenario_03_dimensions.sql" "Load trading books, instruments, curves"

# Step 14: Load scenario 03 fact data
echo "============================================================================"
echo "STEP 14: Load Scenario 03 Fact Data"
echo "============================================================================"
echo "NOTE: This may take 2-3 minutes to generate ETRM and forecast data..."
execute_sql "$SQL_DIR/13_load_scenario_03_facts.sql" "Generate ETRM positions, forecasts, mismatch"

# Step 15: Create Semantic Views (Native Cortex Analyst Objects)
echo "============================================================================"
echo "STEP 15: Create Semantic Views (Native Cortex Analyst)"
echo "============================================================================"
echo "Creating native Semantic Views from YAML specifications..."
echo "Note: Semantic Views provide better governance and lifecycle management than stage files"
echo ""

# Build and deploy Project Risk semantic view (Scenario 01a)
echo "Creating Semantic View: OG_PROJECT_RISK_ASSESSMENT..."
if ./build_semantic_view.sh semantic_views/01a_og_project_risk.yaml /tmp/sv_01a.sql > /dev/null 2>&1; then
    if snow sql --connection "$CONNECTION" --filename /tmp/sv_01a.sql > /dev/null 2>&1; then
        echo "  ✓ OG_PROJECT_RISK_ASSESSMENT created successfully"
    else
        echo "  ✗ Failed to create OG_PROJECT_RISK_ASSESSMENT"
    fi
else
    echo "  ✗ Failed to build SQL for OG_PROJECT_RISK_ASSESSMENT"
fi

# Build and deploy Asset & Inventory semantic view (Scenario 02a)
echo "Creating Semantic View: OG_ASSET_INVENTORY_READINESS..."
if ./build_semantic_view.sh semantic_views/02a_og_asset_inventory.yaml /tmp/sv_02a.sql > /dev/null 2>&1; then
    if snow sql --connection "$CONNECTION" --filename /tmp/sv_02a.sql > /dev/null 2>&1; then
        echo "  ✓ OG_ASSET_INVENTORY_READINESS created successfully"
    else
        echo "  ✗ Failed to create OG_ASSET_INVENTORY_READINESS"
    fi
else
    echo "  ✗ Failed to build SQL for OG_ASSET_INVENTORY_READINESS"
fi

# Build and deploy Hedge Mismatch semantic view (Scenario 03)
echo "Creating Semantic View: HEDGE_MISMATCH_EARLY_WARNING..."
if ./build_semantic_view.sh semantic_views/03_hedge_mismatch.yaml /tmp/sv_03.sql > /dev/null 2>&1; then
    if snow sql --connection "$CONNECTION" --filename /tmp/sv_03.sql > /dev/null 2>&1; then
        echo "  ✓ HEDGE_MISMATCH_EARLY_WARNING created successfully"
    else
        echo "  ✗ Failed to create HEDGE_MISMATCH_EARLY_WARNING"
    fi
else
    echo "  ✗ Failed to build SQL for HEDGE_MISMATCH_EARLY_WARNING"
fi

# Verification
echo ""
echo "============================================================================"
echo "STEP 16: Verification"
echo "============================================================================"

echo "Checking row counts..."
snow sql --connection "$CONNECTION" --query "
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- Shared tables
SELECT 'DIM_TIME' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM DIM_TIME
UNION ALL SELECT 'DIM_SITE', COUNT(*) FROM DIM_SITE
UNION ALL SELECT 'DIM_WEATHER_MODEL', COUNT(*) FROM DIM_WEATHER_MODEL
UNION ALL SELECT 'DIM_ASSET', COUNT(*) FROM DIM_ASSET
UNION ALL SELECT 'FCT_WEATHER_FORECAST', COUNT(*) FROM FCT_WEATHER_FORECAST
-- Scenario 01a
UNION ALL SELECT 'DIM_PROJECT', COUNT(*) FROM DIM_PROJECT
UNION ALL SELECT 'DIM_ACTIVITY', COUNT(*) FROM DIM_ACTIVITY
UNION ALL SELECT 'FCT_PROJECT_DELAY_EVENT', COUNT(*) FROM FCT_PROJECT_DELAY_EVENT
-- Scenario 02a
UNION ALL SELECT 'DIM_WAREHOUSE', COUNT(*) FROM DIM_WAREHOUSE
UNION ALL SELECT 'DIM_SKU', COUNT(*) FROM DIM_SKU
UNION ALL SELECT 'FCT_MAINTENANCE_HISTORY', COUNT(*) FROM FCT_MAINTENANCE_HISTORY
UNION ALL SELECT 'FCT_INVENTORY_ON_HAND', COUNT(*) FROM FCT_INVENTORY_ON_HAND
-- Scenario 03
UNION ALL SELECT 'DIM_TRADING_BOOK', COUNT(*) FROM DIM_TRADING_BOOK
UNION ALL SELECT 'DIM_INSTRUMENT', COUNT(*) FROM DIM_INSTRUMENT
UNION ALL SELECT 'FCT_ETRM_POSITIONS', COUNT(*) FROM FCT_ETRM_POSITIONS
UNION ALL SELECT 'FCT_PRODUCTION_FORECAST', COUNT(*) FROM FCT_PRODUCTION_FORECAST
UNION ALL SELECT 'FCT_MISMATCH_RISK', COUNT(*) FROM FCT_MISMATCH_RISK
ORDER BY TABLE_NAME;
"

echo ""
echo "============================================================================"
echo "DEPLOYMENT COMPLETE!"
echo "============================================================================"
echo ""
echo "Database: ENERGY_WEATHER_EVENT"
echo "Schema: ENERGY_DATA"
echo "Warehouse: ENERGY_WEATHER_EVENT_WH"
echo "Role: ENERGY_WEATHER_EVENT_ROLE"
echo ""
echo "Cortex Analyst Semantic Views (Native Objects):"
echo "  1. OG_PROJECT_RISK_ASSESSMENT - Project risk and weather delay analysis"
echo "     Source: ./semantic_views/01a_og_project_risk.yaml"
echo ""
echo "  2. OG_ASSET_INVENTORY_READINESS - Asset failure prediction and spare parts inventory"
echo "     Source: ./semantic_views/02a_og_asset_inventory.yaml"
echo ""
echo "  3. HEDGE_MISMATCH_EARLY_WARNING - Trading risk and hedge-physical volume mismatch"
echo "     Source: ./semantic_views/03_hedge_mismatch.yaml"
echo ""
echo "Benefits of Semantic Views:"
echo "  - Better governance and access control"
echo "  - Version control with COPY GRANTS"
echo "  - Native Snowflake object lifecycle"
echo "  - No stage file management needed"
echo ""
echo "Next Steps:"
echo "  1. Run ./run.sh to verify the deployment"
echo "  2. Use Cortex Analyst with the semantic models in ./analyst/"
echo "  3. Query the data using the ENERGY_WEATHER_EVENT database"
echo ""
echo "============================================================================"

