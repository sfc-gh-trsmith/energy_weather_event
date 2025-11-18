#!/bin/bash

# ============================================================================
# clean.sh - Clean Up Energy Weather Event Demo
# ============================================================================
# Purpose: Drop all Snowflake objects for a clean rebuild
# Usage: ./clean.sh
# ============================================================================

set -e  # Exit on error

echo "============================================================================"
echo "Energy Weather Event Demo - Cleanup Script"
echo "============================================================================"
echo ""
echo "WARNING: This will DELETE all demo objects and data!"
echo "  - Database: ENERGY_WEATHER_EVENT"
echo "  - Warehouse: ENERGY_WEATHER_EVENT_WH"
echo "  - Role: ENERGY_WEATHER_EVENT_ROLE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Proceeding with cleanup..."
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

echo "============================================================================"
echo "Dropping Snowflake Objects"
echo "============================================================================"
echo ""

# Drop database (this cascades to all schemas and tables)
echo "Dropping database ENERGY_WEATHER_EVENT..."
if snow sql --connection "$CONNECTION" --query "DROP DATABASE IF EXISTS ENERGY_WEATHER_EVENT CASCADE;" > /dev/null 2>&1; then
    echo "  ✓ Database dropped"
else
    echo "  ✗ Failed to drop database"
fi

# Drop warehouse
echo "Dropping warehouse ENERGY_WEATHER_EVENT_WH..."
if snow sql --connection "$CONNECTION" --query "DROP WAREHOUSE IF EXISTS ENERGY_WEATHER_EVENT_WH;" > /dev/null 2>&1; then
    echo "  ✓ Warehouse dropped"
else
    echo "  ✗ Failed to drop warehouse"
fi

# Drop role
echo "Dropping role ENERGY_WEATHER_EVENT_ROLE..."
if snow sql --connection "$CONNECTION" --query "DROP ROLE IF EXISTS ENERGY_WEATHER_EVENT_ROLE;" > /dev/null 2>&1; then
    echo "  ✓ Role dropped"
else
    echo "  ✗ Failed to drop role"
fi

echo ""
echo "============================================================================"
echo "CLEANUP COMPLETE!"
echo "============================================================================"
echo ""
echo "All demo objects have been removed from Snowflake."
echo ""
echo "To redeploy the demo, run:"
echo "  ./deploy.sh"
echo ""
echo "============================================================================"

