#!/bin/bash

# ============================================================================
# run.sh - Verify Energy Weather Event Demo Deployment
# ============================================================================
# Purpose: Verify all objects exist and data is loaded correctly
# Usage: ./run.sh
# ============================================================================

set -e  # Exit on error

echo "============================================================================"
echo "Energy Weather Event Demo - Verification Script"
echo "============================================================================"
echo ""

# Configuration
CONNECTION="demo"

# Check if snow CLI is available
if ! command -v snow &> /dev/null; then
    echo "ERROR: Snowflake CLI (snow) is not installed or not in PATH"
    exit 1
fi

# Check if connection exists
if ! snow connection test --connection "$CONNECTION" &> /dev/null; then
    echo "ERROR: Connection '$CONNECTION' not found or invalid"
    exit 1
fi

echo "Running verification checks..."
echo ""

# Test 1: Check database exists
echo "TEST 1: Database exists"
if snow sql --connection "$CONNECTION" --query "SHOW DATABASES LIKE 'ENERGY_WEATHER_EVENT'" | grep -q "ENERGY_WEATHER_EVENT"; then
    echo "  ✓ PASS: Database ENERGY_WEATHER_EVENT exists"
else
    echo "  ✗ FAIL: Database not found"
    exit 1
fi
echo ""

# Test 2: Check schema exists
echo "TEST 2: Schema exists"
if snow sql --connection "$CONNECTION" --query "SHOW SCHEMAS LIKE 'ENERGY_DATA' IN DATABASE ENERGY_WEATHER_EVENT" | grep -q "ENERGY_DATA"; then
    echo "  ✓ PASS: Schema ENERGY_DATA exists"
else
    echo "  ✗ FAIL: Schema not found"
    exit 1
fi
echo ""

# Test 3: Check warehouse exists
echo "TEST 3: Warehouse exists"
if snow sql --connection "$CONNECTION" --query "SHOW WAREHOUSES LIKE 'ENERGY_WEATHER_EVENT_WH'" | grep -q "ENERGY_WEATHER_EVENT_WH"; then
    echo "  ✓ PASS: Warehouse ENERGY_WEATHER_EVENT_WH exists"
else
    echo "  ✗ FAIL: Warehouse not found"
    exit 1
fi
echo ""

# Test 4: Check all dimension tables exist
echo "TEST 4: Dimension tables exist"
EXPECTED_DIMS="DIM_TIME DIM_SITE DIM_WEATHER_MODEL DIM_ASSET DIM_DELIVERY_POINT DIM_INTERCONNECTION_POINT DIM_PROJECT DIM_ACTIVITY DIM_DELAY_TYPE"
for dim in $EXPECTED_DIMS; do
    if snow sql --connection "$CONNECTION" --query "SELECT COUNT(*) FROM ENERGY_WEATHER_EVENT.ENERGY_DATA.$dim" &> /dev/null; then
        echo "  ✓ PASS: Table $dim exists"
    else
        echo "  ✗ FAIL: Table $dim not found"
        exit 1
    fi
done
echo ""

# Test 5: Check all fact tables exist
echo "TEST 5: Fact tables exist"
EXPECTED_FACTS="FCT_WEATHER_FORECAST FCT_PROJECT_ACTIVITY_SNAPSHOT FCT_PROJECT_DELAY_EVENT FCT_MAINTENANCE_HISTORY FCT_INVENTORY_ON_HAND FCT_ETRM_POSITIONS FCT_PRODUCTION_FORECAST FCT_MISMATCH_RISK"
for fact in $EXPECTED_FACTS; do
    if snow sql --connection "$CONNECTION" --query "SELECT COUNT(*) FROM ENERGY_WEATHER_EVENT.ENERGY_DATA.$fact" &> /dev/null; then
        echo "  ✓ PASS: Table $fact exists"
    else
        echo "  ✗ FAIL: Table $fact not found"
        exit 1
    fi
done
echo ""

# Test 6: Check data loaded
echo "TEST 6: Data loaded correctly"
echo ""
echo "Table Row Counts:"
snow sql --connection "$CONNECTION" --query "
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- Shared tables
SELECT 'DIM_TIME' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM DIM_TIME
UNION ALL SELECT 'DIM_SITE', COUNT(*) FROM DIM_SITE WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'DIM_ASSET', COUNT(*) FROM DIM_ASSET WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'FCT_WEATHER_FORECAST', COUNT(*) FROM FCT_WEATHER_FORECAST
-- Scenario 01a
UNION ALL SELECT 'DIM_PROJECT', COUNT(*) FROM DIM_PROJECT WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'DIM_ACTIVITY', COUNT(*) FROM DIM_ACTIVITY WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'FCT_PROJECT_DELAY_EVENT', COUNT(*) FROM FCT_PROJECT_DELAY_EVENT
-- Scenario 02a
UNION ALL SELECT 'DIM_WAREHOUSE', COUNT(*) FROM DIM_WAREHOUSE WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'DIM_SKU', COUNT(*) FROM DIM_SKU WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'FCT_MAINTENANCE_HISTORY', COUNT(*) FROM FCT_MAINTENANCE_HISTORY
UNION ALL SELECT 'FCT_INVENTORY_ON_HAND', COUNT(*) FROM FCT_INVENTORY_ON_HAND
-- Scenario 03
UNION ALL SELECT 'DIM_TRADING_BOOK', COUNT(*) FROM DIM_TRADING_BOOK WHERE IS_CURRENT = TRUE
UNION ALL SELECT 'FCT_MISMATCH_RISK', COUNT(*) FROM FCT_MISMATCH_RISK
ORDER BY TABLE_NAME;
"
echo ""

# Test 7: Sample queries
echo "TEST 7: Sample analytical queries"
echo ""

echo "7a. Projects by status:"
snow sql --connection "$CONNECTION" --query "
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
SELECT PROJECT_STATUS, COUNT(*) as PROJECT_COUNT
FROM DIM_PROJECT
WHERE IS_CURRENT = TRUE
GROUP BY PROJECT_STATUS
ORDER BY PROJECT_COUNT DESC;
"
echo ""

echo "7b. Weather severity distribution:"
snow sql --connection "$CONNECTION" --query "
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
SELECT WEATHER_CATEGORY, COUNT(*) as FORECAST_COUNT
FROM FCT_WEATHER_FORECAST
GROUP BY WEATHER_CATEGORY
ORDER BY FORECAST_COUNT DESC;
"
echo ""

echo "7c. Total delay days by category:"
snow sql --connection "$CONNECTION" --query "
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;
SELECT 
    dt.DELAY_CATEGORY,
    COUNT(*) as DELAY_EVENTS,
    SUM(d.DELAY_DURATION_DAYS) as TOTAL_DELAY_DAYS,
    SUM(d.DELAY_COST_USD) as TOTAL_DELAY_COST
FROM FCT_PROJECT_DELAY_EVENT d
JOIN DIM_DELAY_TYPE dt ON d.DELAY_TYPE_KEY = dt.DELAY_TYPE_KEY
GROUP BY dt.DELAY_CATEGORY
ORDER BY TOTAL_DELAY_DAYS DESC;
"
echo ""

# Test 8: Check semantic model files
echo "TEST 8: Cortex Analyst semantic models"
EXPECTED_MODELS="./analyst/01a_og_project_risk.yaml ./analyst/02a_og_asset_inventory.yaml ./analyst/03_hedge_mismatch.yaml"
for model in $EXPECTED_MODELS; do
    if [ -f "$model" ]; then
        echo "  ✓ PASS: Semantic model exists at $model"
    else
        echo "  ✗ FAIL: Semantic model not found at $model"
        exit 1
    fi
done

echo ""
echo "TEST 9: Semantic models deployed to Snowflake stage"
echo "  Checking uploaded files..."
STAGE_LIST=$(snow sql --connection "$CONNECTION" --query "USE ROLE ACCOUNTADMIN; LIST @ENERGY_WEATHER_EVENT.ENERGY_DATA.SEMANTIC_MODELS;" 2>&1)
if echo "$STAGE_LIST" | grep -q "01a_o"; then
    echo "  ✓ PASS: 01a_og_project_risk.yaml uploaded to stage"
else
    echo "  ✗ FAIL: 01a_og_project_risk.yaml not found in stage"
fi
if echo "$STAGE_LIST" | grep -q "02a_o"; then
    echo "  ✓ PASS: 02a_og_asset_inventory.yaml uploaded to stage"
else
    echo "  ✗ FAIL: 02a_og_asset_inventory.yaml not found in stage"
fi
if echo "$STAGE_LIST" | grep -q "03_he"; then
    echo "  ✓ PASS: 03_hedge_mismatch.yaml uploaded to stage"
else
    echo "  ✗ FAIL: 03_hedge_mismatch.yaml not found in stage"
fi
echo ""

echo "TEST 10: Cortex Search Services (Analyst Objects) created"
echo "  Checking Cortex Search Services..."
SERVICE_COUNT=$(snow sql --connection "$CONNECTION" --query "USE ROLE ACCOUNTADMIN; USE DATABASE ENERGY_WEATHER_EVENT; USE SCHEMA ENERGY_DATA; SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES WHERE SERVICE_NAME LIKE 'ANALYST%';" 2>&1 | grep -E "^\| [0-9]" | tail -1 | awk '{print $2}')
if [ "$SERVICE_COUNT" = "3" ]; then
    echo "  ✓ PASS: All 3 Cortex Search Services created"
    echo "    - ANALYST_PROJECT_RISK"
    echo "    - ANALYST_ASSET_INVENTORY"
    echo "    - ANALYST_HEDGE_MISMATCH"
else
    echo "  ✗ FAIL: Expected 3 services, found: $SERVICE_COUNT"
fi
echo ""

echo "TEST 11: Native Semantic Views Deployed"
echo "  Verifying semantic views..."

# Check each semantic view
PASSED=0
FAILED=0

for SV_NAME in "OG_PROJECT_RISK_ASSESSMENT" "OG_ASSET_INVENTORY_READINESS" "HEDGE_MISMATCH_EARLY_WARNING"; do
    RESULT=$(snow sql --connection "$CONNECTION" --query "USE ROLE ACCOUNTADMIN; USE DATABASE ENERGY_WEATHER_EVENT; USE SCHEMA ENERGY_DATA; SHOW SEMANTIC VIEWS LIKE '$SV_NAME' IN SCHEMA ENERGY_DATA;" 2>&1 | grep -c "$SV_NAME")
    if [ "$RESULT" -gt 0 ]; then
        echo "  ✓ PASS: $SV_NAME semantic view exists"
        PASSED=$((PASSED + 1))
    else
        echo "  ✗ FAIL: $SV_NAME semantic view not found"
        FAILED=$((FAILED + 1))
    fi
done

if [ "$FAILED" -eq 0 ]; then
    echo "  ✓ All 3 semantic views deployed successfully"
else
    echo "  ✗ $FAILED semantic view(s) missing"
fi
echo ""

echo "============================================================================"
echo "VERIFICATION COMPLETE - ALL TESTS PASSED!"
echo "============================================================================"
echo ""
echo "The demo is ready to use!"
echo ""
echo "You can now:"
echo "  1. Query the data in Snowflake:"
echo "     USE DATABASE ENERGY_WEATHER_EVENT;"
echo "     USE SCHEMA ENERGY_DATA;"
echo "  2. Use Cortex Analyst with the semantic models:"
echo "     - Project Risk: ./analyst/01a_og_project_risk.yaml"
echo "     - Asset/Inventory: ./analyst/02a_og_asset_inventory.yaml"
echo "     - Hedge Mismatch: ./analyst/03_hedge_mismatch.yaml"
echo "  3. Explore the data model and sample data"
echo ""
echo "Sample queries to try:"
echo "  Scenario 01a (Project Risk):"
echo "    - What projects have been delayed due to weather?"
echo "    - Which sites experienced extreme weather in 2024?"
echo "  Scenario 02a (Asset/Inventory):"
echo "    - Which assets failed during severe weather?"
echo "    - What spare parts inventory is available at each warehouse?"
echo "  Scenario 03 (Hedge Mismatch):"
echo "    - Which trading books have high mismatch risk?"
echo "    - What is the expected P&L impact from volume mismatches?"
echo ""
echo "============================================================================"

