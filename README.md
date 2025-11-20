# Energy Weather Event Demo

A set of demos focused on simulating extreme weather events and their repercussions across the energy industry, demonstrating Snowflake's capabilities for data integration, analytics, and AI-driven insights.

## Overview

This repository contains data models, sample data, and Cortex Analyst semantic models for simulating weather-driven risks in the energy industry. The implementation supports **multi-industry scenarios** using a Line of Business (LOB) architecture pattern:

- **Oil & Gas (O&G)**: Drilling projects, production assets, hedge positions
- **Electric Utilities**: Transmission/substation projects, grid equipment, customer outages

The LOB pattern enables maximum code reuse while maintaining clean separation of industry-specific attributes. See `cursor_scratch/lob_architecture.md` for detailed architecture documentation.

## Project Structure

```
energy_weather_event/
├── README.md                           # This file - Getting started guide
├── DEMO_DESCRIPTION.md                 # High-level demo overview
├── SEMANTIC_VIEWS.md                   # Semantic view documentation
├── requirements/                       # Product requirement documents (5 PRDs)
│   ├── REQUIREMENTS_01A_OG_FIND.md
│   ├── REQUIREMENTS_01B_UTILITIES_FIND.md
│   ├── REQUIREMENTS_02A_OG_PRODUCE_AND_MOVE.md
│   ├── REQUIREMENTS_02B_UTILITIES_PRODUCE_AND_MOVE.md
│   └── REQUIREMENTS_03_HEDGE.md
├── sql/                                # Snowflake DDL and data loading (23 scripts)
│   ├── 00_setup.sql                    # Database, schema, role, warehouse setup
│   ├── 00a_lob_dimension.sql           # Line of Business dimension
│   ├── 01_shared_dimensions.sql        # Shared dimensions (TIME, SITE, ASSET)
│   ├── 02_shared_facts.sql             # Shared facts (weather forecasts)
│   ├── 03-13_*.sql                     # O&G scenarios (01a, 02a, 03)
│   ├── 16a-16b_*_extensions.sql        # LOB extension tables
│   ├── 17-18_*_util_*.sql              # Utilities scenarios (01b, 02b)
│   └── 19-22_load_*.sql                # LOB and utilities data loading
├── semantic_views/                     # Cortex Analyst semantic views (5 YAMLs)
│   ├── 01a_og_project_risk.yaml        # O&G project risk
│   ├── 01b_util_project_risk.yaml      # Utilities project risk
│   ├── 02a_og_asset_inventory.yaml     # O&G asset & inventory
│   ├── 02b_util_asset_inventory.yaml   # Utilities asset & customer
│   └── 03_hedge_mismatch.yaml          # Hedge mismatch (multi-LOB)
├── data/                               # Reference documents (2 PDFs)
├── deploy.sh                           # Deploy all objects and data
├── clean.sh                            # Clean up all objects
├── run.sh                              # Verify deployment
├── build_semantic_view.sh              # YAML to SQL converter
└── cursor_scratch/                     # Working documents & specifications
    ├── lob_architecture.md             # LOB architecture design
    ├── CORTEX_AGENT_OG.md              # O&G agent configuration spec
    ├── CORTEX_AGENT_UTILITIES.md       # Utilities agent configuration spec
    ├── CORTEX_ANALYST.md               # Cortex Analyst deployment guide
    ├── PROJECT_STRUCTURE.md            # Detailed project structure
    ├── REQUIREMENTS_SPEC.md            # Requirements document standard
    └── *.md, *.log, *.py               # Implementation docs and logs
```

**Note**: The `cursor_scratch/` directory contains detailed specifications and working documents. See the README there for more information.

## Scenarios

### Oil & Gas Scenarios (All Implemented)

**Multi-View Queries:**
For questions spanning multiple domains (e.g., "How do asset failures impact our hedge positions?"), query relevant views sequentially and synthesize results.

## Complex Multi-Domain Questions

These questions require orchestrating queries across multiple semantic views and synthesizing insights:

### Project Risk + Asset Operations
- **"Which construction projects are delayed due to weather, and do we have sufficient inventory at nearby warehouses to support accelerated catch-up work once weather clears?"**
  - *Query OG_PROJECT_RISK_ASSESSMENT* for delayed projects and weather windows
  - *Query OG_ASSET_INVENTORY_READINESS* for warehouse inventory levels and equipment availability
  - *Synthesize:* Match project locations to nearest warehouses and assess readiness

- **"For sites experiencing extreme weather this week, what critical assets are at risk of failure, and which active construction activities should we pause?"**
  - *Query OG_PROJECT_RISK_ASSESSMENT* for active projects and weather forecasts
  - *Query OG_ASSET_INVENTORY_READINESS* for asset failure probability and weather correlation
  - *Synthesize:* Create risk matrix by site showing both project and asset exposure

### Asset Operations + Trading Risk
- **"If our top 3 highest-risk assets fail during the forecasted weather event, what would be the production shortfall and resulting hedge mismatch exposure?"**
  - *Query OG_ASSET_INVENTORY_READINESS* for failure probability, production impact, and downtime estimates
  - *Query HEDGE_MISMATCH_EARLY_WARNING* for hedge positions and mismatch calculations
  - *Synthesize:* Calculate scenario analysis of asset failure → production loss → volume mismatch → financial impact

- **"Show me trading books with critical mismatch risk where the primary driver is weather-impacted asset downtime rather than normal production variance."**
  - *Query OG_ASSET_INVENTORY_READINESS* for weather-correlated maintenance events and production losses
  - *Query HEDGE_MISMATCH_EARLY_WARNING* for mismatch risk drivers and weather contribution percentages
  - *Synthesize:* Filter and rank books by weather-driven asset failures as root cause

### Project Risk + Trading Risk
- **"How do current project delays impact our expected production ramp timeline, and should we adjust our forward hedge positions for Q2-Q3 delivery?"**
  - *Query OG_PROJECT_RISK_ASSESSMENT* for project completion forecasts and schedule variances
  - *Query HEDGE_MISMATCH_EARLY_WARNING* for hedge positions and production forecasts by delivery period
  - *Synthesize:* Align delayed project completions with hedge positions to identify over-hedged periods

### All Three Domains (Comprehensive Risk View)
- **"Provide a comprehensive weather risk assessment for the Permian Basin: active project delays, at-risk production assets, current inventory readiness, and hedge position exposure for the next 30 days."**
  - *Query OG_PROJECT_RISK_ASSESSMENT* for Permian projects, delays, and weather forecasts
  - *Query OG_ASSET_INVENTORY_READINESS* for asset health, failure risk, and spare parts availability
  - *Query HEDGE_MISMATCH_EARLY_WARNING* for hedge positions and forecasted mismatches
  - *Synthesize:* Create unified regional risk dashboard with cross-domain dependencies

- **"What is our total financial exposure to the forecasted hurricane including project delays, unplanned asset downtime, emergency inventory costs, and hedge mismatch penalties?"**
  - *Query all three views* for cost impacts, delay costs, maintenance costs, inventory costs, and financial penalties
  - *Synthesize:* Aggregate all cost components into total hurricane exposure scenario


1. **01a - Project Risk Assessment (Find)** ✅
   - Track weather impacts on capital project delays
   - Monitor drilling, pipeline, and facility construction projects
   - Analyze schedule performance and weather correlations
   - Core entities: Projects, Activities, Sites, Weather, Historical Delays
   
   **User Personas & Questions:**
   - *Project Manager*: "Show me all of my active projects that are currently behind schedule due to weather-related delays, including the project name, site location, number of delay days, delay cost in dollars, and the specific weather events that caused each delay. Order by total delay cost descending." | "What's the total delay cost for each individual project located in the Permian Basin region, along with project name, approved budget, current cost variance, current schedule variance, and project manager? Calculate delay cost as a percentage of approved budget and order by that percentage descending."
   - *Construction Lead*: "Which sites are experiencing or forecasted to experience severe or extreme weather in the next 7 days? For each site, show the site name, region, weather condition type, maximum weather severity score expected, temperature range, wind speed, and precipitation amount. Also list which active projects and critical path activities at each site could be impacted, ordered by weather severity score descending." | "Show me all weather-sensitive activities that are on the critical path for active projects, including project name, activity name, activity type, planned start and end dates, total float days, specific weather constraints for that activity, and the current weather forecast for the site location during the activity window. Order by float days ascending to prioritize the highest risk activities."
   - *Portfolio Executive*: "What's the aggregate weather-related schedule variance in days across all active projects, broken down by region and portfolio? Include the number of projects per region, total approved budget, total delay cost to date, average schedule performance index, and percentage of budget consumed by weather delays. Order by total delay cost descending." | "Which geographic regions have the highest weather risk exposure based on historical delay frequency and severity? Show the region name, number of active projects, total project value in dollars, count of severe weather events in the past 12 months, average weather severity score, total weather-related delay days, and percentage of projects that have experienced weather delays. Rank regions by a combination of frequency and financial impact."

2. **02a - Asset & Inventory Readiness (Produce & Move)** ✅
   - Predict equipment failures from weather events
   - Match at-risk assets to spare parts inventory
   - Track maintenance history and production impact
   - Core entities: Assets, Equipment, Parts, Warehouses, Telemetry, Maintenance History
   
   **User Personas & Questions:**
   - *Maintenance Manager*: "Which assets are predicted to have the highest failure probability during the forecasted cold snap next week? For each asset, show the asset name, site location, asset type, current failure probability score, remaining useful life in days, last maintenance date, current health score, and whether we have the required spare parts in stock at nearby warehouses. Order by failure probability descending and highlight assets where parts are not available within 24 hours." | "For all compressor assets currently flagged as high-risk, do we have the necessary spare parts available? Show the asset ID, asset name, site location, required SKU descriptions, quantity needed per asset, current on-hand quantity by warehouse location, warehouse distance from asset site, reorder point threshold, and supplier lead time in days. Flag any parts where on-hand inventory is below the safety stock level."
   - *Operations Manager*: "What was the total production downtime in hours from weather-related equipment failures last quarter, broken down by asset type, failure type, and site location? For each breakdown category, include the number of failure events, average downtime per event, total maintenance cost, production volume lost, estimated revenue impact in dollars, and the specific weather conditions present during each failure (temperature, wind, precipitation). Compare these metrics to the same quarter last year to identify trends." | "Show me all assets that have experienced multiple failures during extreme weather events in the past 18 months, including asset name, asset type, site location, total number of failures, types of weather events during failures (freeze, heat, storm), average time between failures, cumulative downtime hours, total maintenance costs, and whether the asset is flagged for replacement or upgrade. Identify patterns in failure conditions and rank assets by total operational impact."
   - *Supply Chain Manager*: "Which warehouses currently have critical spare parts inventory levels below the reorder point? For each warehouse, show the warehouse name, location, SKU descriptions that are low, current quantity on hand, reorder point threshold, safety stock level, average monthly demand, days of supply remaining, number of at-risk assets that depend on each part, supplier name, and procurement lead time. Order by days of supply remaining ascending and highlight parts supporting assets with imminent failure risk." | "What is the average supplier lead time for spare parts needed by assets currently flagged as high failure risk? Show the SKU description, primary supplier name, normal lead time, expedited lead time if available, unit cost, total cost for required quantity, current inventory across all warehouse locations, which specific high-risk assets need each part, and recommended order quantity to maintain 90 days of supply. Also identify any single-source parts that create supply chain vulnerability."

3. **03 - Hedge Mismatch Early Warning** ✅
   - Compare financial hedges vs. physical production forecasts
   - Identify volume mismatch risks between trading positions and deliverable production
   - Analyze P&L impact from forecast deviations
   - Core entities: Trading Books, ETRM Positions, Production Forecasts, Curves, Mismatch Analysis
   
   **User Personas & Questions:**
   - *Trading Manager*: "Which trading books have the largest absolute volume mismatches for Q1 2025 delivery months? For each book, show the book name, delivery month, commodity type, total hedged volume, P50 forecasted production volume, mismatch volume in units, mismatch as a percentage of hedge position, expected mismatch probability, current market price, estimated mark-to-market exposure in dollars, and primary risk driver. Order by absolute mismatch volume descending and highlight mismatches exceeding 15% threshold." | "For February 2025 deliveries, are we over-hedged or under-hedged on each trading book and delivery point? Show the book name, delivery point location, instrument type, net hedge position volume, P50 production forecast, P10 and P90 forecast ranges for downside/upside scenarios, mismatch magnitude, direction of mismatch (long/short physical), current basis price, estimated liquidation cost if we need to cover the position, and recommended trading actions to reduce exposure. Group by book and rank by financial exposure."
   - *Risk Manager*: "What is the total Value-at-Risk impact from hedge mismatches across all trading books, broken down by book, commodity type, and delivery month? For each category, show the VaR amount at 95% confidence level, primary risk drivers contributing to the mismatch (weather forecast uncertainty, production decline, well performance), stress test scenarios showing P&L impact under 10th percentile production outcomes, current risk level classification (normal/elevated/critical), days since last risk review, and whether the exposure exceeds established risk limits. Prioritize books with critical risk levels or limit breaches." | "Which delivery months in the next 12 months have critical risk level classifications that require immediate hedging actions? For each month, display the delivery month, trading books affected, total mismatch volume, mismatch probability weighted by forecast uncertainty, current market conditions (price, volatility, liquidity), VaR impact in dollars, comparison to risk limit thresholds, historical mismatch frequency for that month, recommended hedge adjustments (volume and instrument type), estimated trading cost to rebalance, and deadline for action before delivery month. Create an action priority ranking based on risk level, time to delivery, and market conditions."
   - *Finance Executive*: "Run a scenario analysis showing our expected P&L impact across all trading books if weather events reduce physical production by 5%, 10%, 15%, and 20% below P50 forecast. For each scenario and each book, show the forecasted production shortfall in units, existing hedge coverage ratio, uncovered volume requiring market purchases, estimated basis cost to cover positions, total P&L impact in dollars, percentage impact to quarterly EBITDA, which commodity types and delivery points are most exposed, and the probability of each scenario occurring based on historical weather patterns and current forecast uncertainty. Summarize total enterprise exposure and rank scenarios by likelihood and impact severity." | "Which trading books contribute the most to our overall hedge mismatch exposure in absolute dollars and as a percentage of total risk? For each book, show the book name, managed volume, average hedge ratio, total VaR exposure, percentage contribution to enterprise VaR, trend in mismatch over the past 6 months (improving/worsening), number of delivery months with critical risk, book manager responsible, primary commodities traded, and breakdown of risk drivers (forecast uncertainty, weather impact, well performance). Identify concentration risks where a single book represents more than 25% of total exposure and recommend portfolio rebalancing strategies."

### Electric Utilities Scenarios (All Implemented)

1. **01b - Utilities Project Risk Assessment (Find)** ✅
   - Track weather impacts on transmission and distribution project delays
   - Monitor transmission lines, substations, and distribution upgrades
   - Analyze schedule performance and weather correlations
   - Core entities: Projects, Activities, Sites, Weather, Historical Delays (same as O&G with utilities extensions)
   
   **User Personas & Questions:**
   - *Project Manager*: "Show me all active transmission line projects currently behind schedule due to weather delays, including project name, voltage level, circuit miles, delay days, delay cost, and specific weather events. Order by delay cost descending."
   - *Construction Lead*: "Which service territories are forecasted to experience ice storms or high winds in the next 7 days? For each territory, show active aerial construction activities that should be suspended, including project type, work height, weather constraints (max wind speed), and estimated customer connections affected by delays."
   - *Portfolio Executive*: "What's the total weather-related schedule variance across all transmission and substation projects by region? Include count of projects, approved budgets, delay costs, and impact to SAIDI reliability improvement targets. Order by total delay cost descending."

2. **02b - Utilities Asset & Inventory Readiness (Produce & Move)** ✅
   - Predict grid equipment failures from weather events
   - Track customer outages and SAIDI/SAIFI/CAIDI reliability metrics
   - Match at-risk assets to replacement equipment inventory
   - Core entities: Assets (transformers, circuit breakers, towers), Customers, Reliability Circuits, Outage Events
   
   **User Personas & Questions:**
   - *Grid Operations Manager*: "Which transformers and circuit breakers have the highest failure probability during the forecasted storm? For each asset, show voltage rating, customers affected, SAIDI contribution, current health score, and whether we have replacement equipment available. Order by customer impact descending."
   - *Reliability Manager*: "What was our SAIDI performance last quarter broken down by circuit and failure cause? For weather-related outages, show total customer-minutes lost, average restoration time (MTTR), number of customers affected per event, and comparison to regulatory targets. Flag circuits that exceeded SAIDI targets."
   - *Distribution Manager*: "Show all critical customers (hospitals, emergency services) served by assets flagged as high failure risk. For each customer, show service address, asset dependencies, backup power availability, estimated outage duration if primary asset fails, and priority restoration order. Identify customers with no backup and recommend redundancy improvements."

## Data Model Architecture

### Multi-LOB Architecture Pattern

The solution uses a **Line of Business (LOB) pattern** to support multiple energy industries while maximizing code reuse:

**Core Principle:**
- **Shared Core Entities**: DIM_PROJECT, DIM_ASSET, DIM_SITE, DIM_ACTIVITY shared across all industries
- **LOB Discriminator**: `LOB_ID` column in core entities references DIM_LINE_OF_BUSINESS
- **Extension Tables**: Industry-specific attributes in 1:1 FK relationship tables (e.g., DIM_PROJECT_OG_EXT, DIM_PROJECT_UTIL_EXT)
- **Semantic View Filtering**: Each semantic view filters by LOB_ID to present industry-specific lens
- **Separate Agents**: Distinct Cortex Agents for O&G and Utilities with industry-specific terminology

**Benefits:**
1. Maximum reuse of core scheduling, delay tracking, and weather impact models
2. Clean separation of industry-specific attributes (no VARIANT columns or sparse nullables)
3. Type safety with explicit column definitions
4. Easy extensibility for future industries (Renewables, Mining, Water, etc.)
5. Data governance via row-level security on LOB_ID

See `cursor_scratch/lob_architecture.md` for comprehensive architecture documentation including entity relationships, attribute mappings, and extension table patterns.

### Unified Dimensional Model

The solution uses a **unified dimensional model** with shared dimensions across all scenarios and LOBs:

#### Shared Dimensions
- **DIM_TIME** - Date/time dimension for temporal analysis
- **DIM_SITE** - Geographic locations (project sites, production facilities, warehouses)
- **DIM_WEATHER_MODEL** - Weather forecast data sources (NOAA, ECMWF, AccuWeather)
- **DIM_ASSET** - Physical equipment and production assets
- **DIM_DELIVERY_POINT** - Commercial trading delivery locations
- **DIM_INTERCONNECTION_POINT** - Physical grid/pipeline interconnections

#### Shared Facts
- **FCT_WEATHER_FORECAST** - Hourly weather forecasts by site with severity scores

#### Scenario 01a - Project Risk (Oil & Gas)
**Dimensions:**
- **DIM_PROJECT** - Capital projects (drilling, pipelines, facilities)
- **DIM_ACTIVITY** - Project activities from P6/MS Project
- **DIM_DELAY_TYPE** - Categorization of project delays

**Facts:**
- **FCT_PROJECT_ACTIVITY_SNAPSHOT** - Daily/weekly activity progress tracking
- **FCT_PROJECT_DELAY_EVENT** - Historical delay events with weather correlation

#### Scenario 02a - Asset & Inventory Readiness (Oil & Gas)
**Dimensions:**
- **DIM_WAREHOUSE** - Spare parts storage locations
- **DIM_SKU** - Spare parts catalog
- **DIM_BOM** - Bill of Materials (asset to SKU mapping)
- **DIM_FAILURE_TYPE** - Equipment failure classifications
- **DIM_PRODUCTION_UNIT** - Production facilities/lines
- **DIM_IMPACT_MODE** - Production impact modes (OEE categories)

**Facts:**
- **FCT_ASSET_TELEMETRY** - Hourly asset sensor readings
- **FCT_MAINTENANCE_HISTORY** - Historical failures and maintenance events
- **FCT_INVENTORY_ON_HAND** - Spare parts inventory by location
- **FCT_PRODUCTION_VOLUME** - Daily production actuals and OEE metrics
- **FCT_ASSET_IMPACT** - Production loss attribution to assets

#### Scenario 03 - Hedge Mismatch Early Warning
**Dimensions:**
- **DIM_TRADING_BOOK** - Trading books/portfolios
- **DIM_INSTRUMENT** - Trading instruments and contracts
- **DIM_CURVE** - Forward price curves
- **DIM_FORECAST_VERSION** - Production forecast versions

**Facts:**
- **FCT_ETRM_POSITIONS** - Financial hedge positions from trading system
- **FCT_PRODUCTION_FORECAST** - Physical production forecasts (P10/P50/P90)
- **FCT_CURVE_DATA** - Forward curve prices and volatility
- **FCT_PHYSICAL_DELIVERY** - Physical delivery schedules and actuals
- **FCT_MISMATCH_RISK** - Mismatch analysis comparing hedges vs. production

### Sample Data

- **Time Range**: 2024-2025 (2 years, 730 days)
- **Sites**: 15 locations across major US oil & gas basins
  - Permian Basin (Texas, New Mexico)
  - Eagle Ford Shale (Texas)
  - Bakken Formation (North Dakota)
  - Gulf Coast (Texas, Louisiana)
  - Marcellus Shale (Pennsylvania, West Virginia)

**Scenario 01a (Project Risk):**
- **Projects**: 10 capital projects (drilling, pipelines, facilities) - $28M to $285M budgets
- **Activities**: 30+ critical path activities
- **Delay Events**: 10 historical weather-related delays with costs
- **Weather Events**: 4 severe events (hurricane, freeze, thunderstorms, blizzard)

**Scenario 02a (Asset & Inventory):**
- **Assets**: 10 production assets (compressors, pumps, turbines)
- **Warehouses**: 5 spare parts locations across the US
- **SKUs**: 10 critical spare parts with costs and lead times
- **Maintenance Events**: 10 failure events correlated with weather
- **Inventory Snapshots**: Weekly inventory levels (2024-2025)
- **Telemetry**: Hourly sensor readings for November-December 2024

**Scenario 03 (Hedge Mismatch):**
- **Trading Books**: 5 commodity trading books
- **Instruments**: 8 trading instruments (futures, swaps, physical contracts)
- **Curves**: 5 forward price curves (WTI, Henry Hub, basis curves)
- **ETRM Positions**: Monthly hedge positions through 2025
- **Production Forecasts**: 10 forecast versions with P10/P50/P90 scenarios
- **Mismatch Analyses**: Calculated risks for forward months with alerts

## Quick Start

### Prerequisites

1. **Snowflake Account** with appropriate privileges
2. **Snowflake CLI** installed:
   ```bash
   pip install snowflake-cli-labs
   ```
3. **Named Connection** configured:
   ```bash
   snow connection add --connection demo
   ```

### Deployment

1. **Deploy the demo** (creates all objects and loads data):
   ```bash
   ./deploy.sh
   ```
   This will:
   - Create database `ENERGY_WEATHER_EVENT`
   - Create schema `ENERGY_DATA`
   - Create warehouse `ENERGY_WEATHER_EVENT_WH`
   - Create role `ENERGY_WEATHER_EVENT_ROLE`
   - Create all dimension and fact tables
   - Load sample data (~730 days of weather, 10 projects, 30+ activities)

2. **Verify deployment**:
   ```bash
   ./run.sh
   ```
   This validates all objects exist and data is loaded correctly.

3. **Clean up** (when done):
   ```bash
   ./clean.sh
   ```
   This drops all objects for a clean rebuild.

## Using Cortex Analyst

Five Cortex Analyst semantic views are available (3 for O&G, 2 for Utilities):

**Oil & Gas Semantic Views:**
```
semantic_views/01a_og_project_risk.yaml           → OG_PROJECT_RISK_ASSESSMENT
semantic_views/02a_og_asset_inventory.yaml        → OG_ASSET_INVENTORY_READINESS
semantic_views/03_hedge_mismatch.yaml             → HEDGE_MISMATCH_EARLY_WARNING
```

**Electric Utilities Semantic Views:**
```
semantic_views/01b_util_project_risk.yaml         → UTIL_PROJECT_RISK_ASSESSMENT
semantic_views/02b_util_asset_inventory.yaml      → UTIL_ASSET_INVENTORY_READINESS
```

**Cortex Agent Configurations:**
- `CORTEX_AGENT_OG.md` - Oil & Gas agent with drilling, production, and hedge trading context
- `CORTEX_AGENT_UTILITIES.md` - Electric Utilities agent with grid, customer reliability, and SAIDI/SAIFI context

Each semantic view includes LOB filters to ensure data segregation (e.g., `LOB_ID = 'OG'` or `LOB_ID = 'UTILITIES'`)

### Sample Questions to Ask Cortex Analyst:

**Scenario 01a (Project Risk):**
- "What projects have been delayed due to weather in 2024?"
- "Which sites experienced extreme weather conditions?"
- "Show me the total cost of weather-related delays by project"
- "What is the schedule performance index for active projects?"
- "Which critical path activities are weather sensitive?"

**Scenario 02a (Asset & Inventory):**
- "Which assets failed during severe weather events?"
- "What is the total cost of equipment failures by asset type?"
- "Show me spare parts inventory levels by warehouse"
- "Which parts have high stockout risk?"
- "What is the average downtime for weather-related failures?"

**Scenario 03 (Hedge Mismatch):**
- "Which trading books have high mismatch risk?"
- "What is the expected P&L impact from volume mismatches?"
- "Show me mismatch probability by delivery month"
- "What are the primary risk drivers for hedge mismatches?"
- "Which books have triggered mismatch alerts?"

## Snowflake Objects

### Database: `ENERGY_WEATHER_EVENT`
- **Schema**: `ENERGY_DATA`
- **Warehouse**: `ENERGY_WEATHER_EVENT_WH` (Medium, auto-suspend after 60s)
- **Role**: `ENERGY_WEATHER_EVENT_ROLE`

### Key Tables

**Shared Across Scenarios:**

| Table | Type | Description | Row Count (Approx) |
|-------|------|-------------|-------------------|
| DIM_TIME | Dimension | Date/time reference | 730 |
| DIM_SITE | Dimension | Geographic locations | 15 |
| DIM_ASSET | Dimension | Physical equipment | 10 |
| DIM_WEATHER_MODEL | Dimension | Weather data sources | 4 |
| FCT_WEATHER_FORECAST | Fact | Daily weather forecasts | ~10,000 |

**Scenario 01a (Project Risk):**

| Table | Type | Description | Row Count (Approx) |
|-------|------|-------------|-------------------|
| DIM_PROJECT | Dimension | Capital projects | 10 |
| DIM_ACTIVITY | Dimension | Project activities | 30 |
| FCT_PROJECT_ACTIVITY_SNAPSHOT | Fact | Activity progress | ~1,500 |
| FCT_PROJECT_DELAY_EVENT | Fact | Historical delays | 10 |

**Scenario 02a (Asset & Inventory):**

| Table | Type | Description | Row Count (Approx) |
|-------|------|-------------|-------------------|
| DIM_WAREHOUSE | Dimension | Parts storage locations | 5 |
| DIM_SKU | Dimension | Spare parts catalog | 10 |
| FCT_MAINTENANCE_HISTORY | Fact | Failure events | 10 |
| FCT_INVENTORY_ON_HAND | Fact | Inventory snapshots | ~5,000 |
| FCT_ASSET_TELEMETRY | Fact | Sensor readings | ~600 |

**Scenario 03 (Hedge Mismatch):**

| Table | Type | Description | Row Count (Approx) |
|-------|------|-------------|-------------------|
| DIM_TRADING_BOOK | Dimension | Trading portfolios | 5 |
| DIM_INSTRUMENT | Dimension | Trading instruments | 8 |
| FCT_ETRM_POSITIONS | Fact | Hedge positions | ~2,000 |
| FCT_PRODUCTION_FORECAST | Fact | Production forecasts | ~400 |
| FCT_MISMATCH_RISK | Fact | Mismatch analyses | ~150 |

## Sample Queries

```sql
USE DATABASE ENERGY_WEATHER_EVENT;
USE SCHEMA ENERGY_DATA;

-- Projects with weather delays
SELECT 
    p.PROJECT_NAME,
    SUM(d.DELAY_DURATION_DAYS) as TOTAL_DELAY_DAYS,
    SUM(d.DELAY_COST_USD) as TOTAL_COST
FROM FCT_PROJECT_DELAY_EVENT d
JOIN DIM_PROJECT p ON d.PROJECT_KEY = p.PROJECT_KEY
JOIN DIM_DELAY_TYPE dt ON d.DELAY_TYPE_KEY = dt.DELAY_TYPE_KEY
WHERE dt.IS_WEATHER_RELATED = TRUE
GROUP BY p.PROJECT_NAME
ORDER BY TOTAL_DELAY_DAYS DESC;

-- Severe weather events by site
SELECT 
    s.SITE_NAME,
    s.REGION,
    COUNT(*) as SEVERE_WEATHER_DAYS,
    AVG(w.WEATHER_SEVERITY_SCORE) as AVG_SEVERITY
FROM FCT_WEATHER_FORECAST w
JOIN DIM_SITE s ON w.SITE_KEY = s.SITE_KEY
WHERE w.WEATHER_CATEGORY IN ('Severe', 'Extreme')
GROUP BY s.SITE_NAME, s.REGION
ORDER BY SEVERE_WEATHER_DAYS DESC;
```

## Technical Details

- **Snowflake Features Used:**
  - Geography data type for site locations
  - Foreign key constraints for referential integrity
  - Indexes for query performance
  - Generator functions for sample data creation
  
- **Data Generation Approach:**
  - Weather data uses UNIFORM() for realistic random values
  - Seasonal and geographic variations in temperature and precipitation
  - Specific severe weather events seeded for demo purposes
  - Activity snapshots generated based on planned schedules with variance

## Next Steps

1. ✅ **Phase 1 Complete**: All three O&G scenarios with Cortex Analyst
   - ✅ Scenario 01a (Project Risk Assessment)
   - ✅ Scenario 02a (Asset & Inventory Readiness)  
   - ✅ Scenario 03 (Hedge Mismatch Early Warning)
2. **Phase 2**: Create Utilities-specific variations (01b, 02b)
3. **Phase 3**: Add Streamlit applications for interactive visualization
4. **Phase 4**: Implement ML models for predictive analytics

## Requirements Documentation

Detailed product requirements are in the `requirements/` directory:
- `REQUIREMENTS_01A_OG_FIND.md` - Oil & Gas Project Risk Assessment (Find)
- `REQUIREMENTS_01B_UTILITIES_FIND.md` - Electric Utilities Project Risk Assessment (Find)
- `REQUIREMENTS_02A_OG_PRODUCE_AND_MOVE.md` - Oil & Gas Asset & Inventory (Produce & Move)
- `REQUIREMENTS_02B_UTILITIES_PRODUCE_AND_MOVE.md` - Electric Utilities Asset & Inventory (Produce & Move)
- `REQUIREMENTS_03_HEDGE.md` - Hedge Mismatch Early Warning (Multi-LOB)

Each requirements document follows a standard business-focused format covering personas, user stories, sample questions, success metrics, and implementation references.

## Detailed Specifications

For detailed technical specifications and implementation guides, see the `cursor_scratch/` directory:
- **LOB Architecture**: `cursor_scratch/lob_architecture.md` - Complete multi-LOB design documentation
- **Agent Configurations**: 
  - `cursor_scratch/CORTEX_AGENT_OG.md` - Oil & Gas agent routing and sample questions
  - `cursor_scratch/CORTEX_AGENT_UTILITIES.md` - Electric Utilities agent routing and sample questions
- **Deployment Guide**: `cursor_scratch/CORTEX_ANALYST.md` - Semantic view deployment instructions
- **Project Structure**: `cursor_scratch/PROJECT_STRUCTURE.md` - Comprehensive file organization guide
- **Requirements Spec**: `cursor_scratch/REQUIREMENTS_SPEC.md` - Requirements document standard format

## Contributing

When extending this demo:
1. Follow the unified dimensional model approach
2. Share dimensions where possible (DIM_TIME, DIM_SITE, DIM_WEATHER_MODEL)
3. Use consistent naming conventions (ENERGY_WEATHER_EVENT_*)
4. Update the Cortex Analyst semantic models
5. Add scenario-specific queries to run.sh for verification

## Support

For questions or issues with this demo, refer to the PRD documents or Snowflake documentation:
- [Snowflake Cortex Analyst Semantic Model Spec](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)
- [Snowflake SQL Reference](https://docs.snowflake.com/en/sql-reference-commands)

