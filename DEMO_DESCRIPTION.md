# Energy Weather Event Demo - Speaking Abstract

## Executive Summary

Weather is the #1 uncontrollable risk for energy operators. This demo shows how Snowflake turns weather uncertainty into a strategic edge across projects, operations, and trading. Using real-world models and a unified dimensional data foundation, we integrate forecasts, asset telemetry, schedules, inventory, and hedge positions in one platform. With Cortex Analyst’s natural language interface and semantic views, business users surface cross-functional insights without SQL: identify capital projects at risk of weather delays and quantify budget impact; predict asset failures during extreme conditions and reconcile nearby spare-part availability to minimize downtime; and detect hedge/production mismatches early to reduce VaR and avoid costly liquidations. Attendees will see sub-second analytics at scale, portfolio-level what‑if scenarios, and a production-ready reference architecture they can adopt quickly. Outcomes: proactive risk management, faster decisions, lower overruns and outages, and protected margins—delivered on a single, governed Snowflake platform spanning Oil & Gas with applicability to Utilities.


## Demo Overview

**Title:** Predicting and Managing Weather-Driven Risk Across the Energy Value Chain

**Duration:** 30-45 minutes

**Target Audience:** Energy industry executives, data & analytics leaders, risk managers, and technical architects

**Industry Focus:** Oil & Gas (with Utilities applications)

---

## Business Challenge

Energy companies face billions of dollars in weather-related operational and financial risks annually:

- **Capital Projects** experience costly delays when severe weather halts construction activities, with average project overruns of 15-25% attributed to weather impacts
- **Production Assets** fail unexpectedly during extreme temperatures, storms, and freezes, causing unplanned downtime and emergency maintenance costs
- **Financial Hedges** become misaligned with physical production when weather events reduce volumes, creating P&L exposure and potential margin erosion

The traditional approach—reactive decision-making based on fragmented data across siloed systems—leaves companies vulnerable to cascading risks that span multiple business units and timeframes.

---

## The Snowflake Solution

This demo illustrates how Snowflake's unified platform enables energy companies to:

1. **Integrate diverse data sources** - Weather forecasts, project schedules, asset telemetry, inventory systems, production forecasts, and trading positions in a single analytical environment
2. **Analyze cross-functional impacts** - Unified dimensional models reveal how weather events propagate through operations and financials
3. **Enable natural language insights** - Cortex Analyst allows business users to ask complex questions without SQL expertise
4. **Support multiple personas** - Project managers, maintenance supervisors, supply chain planners, traders, and risk managers all access the same truth

---

## Demo Scenarios

### Scenario 1: Project Risk Assessment - "Find the Risk"

**Business Context:** A $500M capital projects portfolio spanning 10 major construction sites across volatile weather regions (Gulf Coast hurricanes, Permian heat, Bakken winters).

**The Challenge:** Project managers need real-time visibility into which active projects face weather-related schedule delays, the financial impact of those delays, and which critical path activities are at risk in the coming weeks.

**What We'll Show:**
- Tracking weather impacts on drilling, pipeline, and facility construction projects across 15 geographic sites
- Correlating historical delay events with weather severity scores to quantify schedule variance
- Forecasting 7-day weather risks to critical path activities and calculating float exposure
- Analyzing $2.8M+ in weather-related delay costs by region, project, and weather event type
- Answering questions like: *"Show me all active projects behind schedule due to weather, with delay cost as a percentage of approved budget"*

**Key Insight:** The Permian Basin alone has 3 projects with weather delays consuming 8-12% of approved budgets, signaling need for accelerated contingency planning.

**Data Showcased:**
- 10 capital projects ($28M to $285M budgets)
- 30+ critical path activities
- 10 historical weather delay events
- 730 days of weather forecasts across 15 sites

---

### Scenario 2: Asset & Inventory Readiness - "Produce and Move"

**Business Context:** A production fleet of 10 critical assets (compressors, turbines, pumps) operating in harsh environments, supported by 5 regional spare parts warehouses with 10 critical SKUs.

**The Challenge:** Operations and maintenance teams must predict which assets will fail during forecasted weather events and ensure required spare parts are available at nearby warehouses to minimize downtime and production loss.

**What We'll Show:**
- Predicting equipment failure probability during extreme weather using sensor telemetry and weather forecasts
- Matching at-risk assets to spare parts inventory availability by warehouse location
- Analyzing historical maintenance events correlated with specific weather conditions (freeze, heat, wind, precipitation)
- Calculating production downtime hours and revenue impact from weather-related asset failures
- Identifying critical inventory gaps where parts are below reorder points for high-risk assets
- Answering questions like: *"Which assets have highest failure probability during next week's cold snap, and do we have required spare parts in stock at nearby warehouses?"*

**Key Insight:** 3 compressor assets currently show >75% failure probability during forecasted freeze conditions, but required gaskets and seals are below safety stock at the closest warehouse—requiring expedited procurement to avoid 48+ hours of unplanned downtime.

**Data Showcased:**
- 10 production assets with health scores and failure predictions
- 5 warehouses with real-time inventory levels
- 10 critical SKU parts with supplier lead times
- 600+ hours of asset telemetry readings
- 10 historical failure events with maintenance costs and weather correlation
- 5,000+ inventory snapshots tracking stock levels

---

### Scenario 3: Hedge Mismatch Early Warning - "Protect the Value"

**Business Context:** Five commodity trading books managing $200M+ in hedge positions against forecasted physical production, with monthly delivery obligations through 2025.

**The Challenge:** Trading and risk managers must identify mismatches between financial hedge volumes and physical production forecasts—especially when weather events reduce production below expectations—to avoid costly last-minute market purchases or forced position liquidations.

**What We'll Show:**
- Comparing ETRM hedge positions to P10/P50/P90 production forecasts by delivery month
- Identifying over-hedged and under-hedged positions with volume mismatch percentages
- Calculating Value-at-Risk (VaR) exposure when weather uncertainty increases forecast volatility
- Analyzing primary risk drivers: weather forecast uncertainty, well performance, production decline
- Running scenario analysis showing P&L impact if weather reduces production by 10%, 15%, or 20%
- Flagging critical risk levels that breach established trading limits and require immediate action
- Answering questions like: *"Which trading books have largest volume mismatches for Q1 2025, and what's the mark-to-market exposure?"*

**Key Insight:** February 2025 shows three books with 15-22% volume mismatches (over-hedged) due to winter storm forecasts reducing expected production, creating $3.2M in estimated liquidation cost if not rebalanced within 45 days.

**Data Showcased:**
- 5 trading books with hedge ratios and risk classifications
- 8 instrument types (futures, swaps, physical contracts)
- 2,000+ ETRM hedge positions
- 400+ production forecasts with probability distributions
- 150+ mismatch risk analyses with VaR calculations
- Forward price curves with basis differentials

---

## Technical Architecture Highlights

### Unified Dimensional Data Model
- **Shared dimensions** across all scenarios: Time, Sites, Weather Models, Assets, Delivery Points
- **Scenario-specific facts**: Project activities, maintenance events, ETRM positions, production forecasts
- **Weather integration**: Single source of truth for forecasts used across project planning, asset monitoring, and production forecasting

### Snowflake Capabilities Demonstrated

1. **Data Integration & Modeling**
   - Star schema design with enforced foreign key relationships
   - Geography data types for spatial site analysis
   - Generator functions for realistic sample data creation
   - Time-series data for weather, telemetry, and inventory tracking

2. **Cortex AI - Semantic Views & Analyst**
   - Three semantic view models enabling natural language queries
   - Complex joins handled automatically across 10+ tables per scenario
   - Business-friendly column descriptions and sample values
   - Verified queries providing query hints to improve accuracy

3. **Advanced Analytics**
   - Probabilistic forecasting (P10/P50/P90) for production scenarios
   - Time-series analysis for weather patterns and asset health trends
   - Risk aggregation across portfolio hierarchies
   - What-if scenario modeling for hedge rebalancing

4. **Performance & Scale**
   - 10,000+ weather forecast records across 2 years and 15 sites
   - Sub-second query response for complex multi-table joins
   - Automated warehouse scaling for varying workloads
   - 60-second auto-suspend for cost optimization

---

## Demo Flow

### Act 1: Discovery (10 minutes)
**Set the Stage:** Energy companies are flying blind with fragmented weather risk data
- Show the business problem with real statistics (project overruns, unplanned downtime, hedge losses)
- Introduce the three scenarios and personas that benefit

### Act 2: Project Risk Assessment (8 minutes)
**Persona:** Project Portfolio Manager
- Ask Cortex Analyst: *"Show me active projects behind schedule due to weather, with delay costs"*
- Drill into Permian Basin projects consuming 8-12% of budget in delays
- Forecast view: *"Which sites face extreme weather in next 7 days, and which critical activities are impacted?"*
- **Insight:** Proactive schedule mitigation saves millions

### Act 3: Asset & Inventory (8 minutes)
**Persona:** Maintenance & Operations Manager
- Ask: *"Which assets have highest failure probability during forecasted cold snap?"*
- Show 3 compressors at 75%+ failure risk
- Ask: *"Do we have required spare parts available at nearby warehouses?"*
- Reveal critical inventory gaps below safety stock
- **Insight:** Predictive maintenance + inventory optimization prevents costly unplanned downtime

### Act 4: Hedge Mismatch (8 minutes)
**Persona:** Trading Risk Manager
- Ask: *"Which trading books have largest volume mismatches for Q1 2025?"*
- Highlight February delivery month with 15-22% over-hedge
- Show weather-driven production reduction creating the gap
- Ask: *"Run scenario analysis if production drops 10%, 15%, 20%"*
- Calculate liquidation costs: $3.2M if not rebalanced
- **Insight:** Early warning system protects margins and reduces VaR exposure

### Act 5: Integration & Vision (6 minutes)
**The Power of Unified Platform:**
- Same weather data feeds all three scenarios
- Cross-functional visibility: Operations sees what Trading sees
- Single source of truth eliminates reconciliation
- Natural language democratizes access across roles

**What's Next:**
- Extend to Utilities scenarios (transmission lines, substations, power generation)
- Add ML models for enhanced failure prediction
- Build Streamlit dashboards for executive KPI tracking
- Real-time alerting and workflow automation

---

## Key Takeaways

### For Business Leaders
- **Proactive Risk Management:** Stop reacting to weather events; predict and mitigate them across the value chain
- **Cross-Functional Integration:** Break down silos between projects, operations, supply chain, and trading
- **Accelerated Decision-Making:** Natural language queries reduce time-to-insight from days to seconds
- **Quantified Value:** Demonstrate ROI through reduced delays, lower downtime, and protected margins

### For Technical Leaders
- **Modern Data Architecture:** Unified dimensional models scale from demo to production
- **AI-Ready Platform:** Cortex Analyst and semantic views require no custom ML infrastructure
- **Developer Productivity:** SQL-based semantic models mean analysts can build without engineers
- **Enterprise-Grade:** Security, governance, and performance built in from day one

### For Data & Analytics Teams
- **Self-Service Analytics:** Business users ask questions in natural language, not SQL
- **Faster Time-to-Value:** Pre-built semantic models accelerate deployment by weeks
- **Maintainable & Extensible:** YAML-based semantic views are version-controlled and reusable
- **Best Practices:** Reference implementation demonstrates star schema, fact/dimension design, and relationship modeling

---

## Demo Statistics

**Data Volume:**
- 15 geographic sites across major US energy basins
- 730 days of historical and forecast data (2024-2025)
- 10,000+ weather forecast records
- 10 capital projects with 30+ activities
- 10 production assets with 600+ hours of telemetry
- 5,000+ inventory snapshots
- 2,000+ hedge positions
- 150+ risk analyses

**Business Scenarios:**
- 3 integrated use cases (Project Risk, Asset Operations, Financial Hedging)
- 6+ user personas (Project Managers, Construction Leads, Maintenance Managers, Operations Managers, Traders, Risk Managers)
- 20+ natural language sample questions
- $500M+ in capital project value
- $200M+ in hedge positions under management

**Technical Capabilities:**
- 30+ dimension and fact tables
- 3 semantic view models (YAML-based)
- Cortex Analyst natural language interface
- Star schema with enforced relationships
- Geography, time-series, and probabilistic data types

---

## Why This Demo Matters

**Industry Relevance:**
Weather is the #1 uncontrollable external risk factor for energy companies. This demo addresses a universal pain point with quantifiable financial impact.

**Technology Differentiation:**
Shows Snowflake's unique ability to combine data warehousing, AI/ML, and semantic modeling in a single platform—eliminating the need for fragmented point solutions.

**Architectural Template:**
Provides a production-ready reference implementation that customers can extend to their specific scenarios (utilities, renewables, mining, construction).

**Business-IT Alignment:**
Demonstrates how technical investments directly support strategic business objectives: reduce risk, improve operations, protect margins.

---

## Audience Adaptations

### For C-Suite / Business Executives (20 minutes)
- Focus on business outcomes and ROI
- Skip technical architecture details
- Emphasize cross-functional integration and decision velocity
- Show 1-2 high-impact questions per scenario

### For Data & Analytics Leaders (30 minutes)
- Balance business context with technical implementation
- Highlight semantic view architecture and Cortex Analyst capabilities
- Demonstrate query complexity handled transparently
- Discuss extensibility and customization options

### For Technical Architects / Data Engineers (45 minutes)
- Deep dive into dimensional modeling approach
- Show YAML semantic view structure
- Discuss deployment automation (deploy.sh, run.sh, clean.sh)
- Review data generation techniques and performance optimization
- Q&A on adapting architecture to customer-specific requirements

---

## Pre-Demo Checklist

**Environment Setup:**
- [ ] Snowflake account with Cortex enabled
- [ ] Deploy script executed successfully (`./deploy.sh`)
- [ ] Verification passed (`./run.sh`)
- [ ] All three semantic views visible in Snowsight
- [ ] Test 2-3 sample questions per scenario
- [ ] Backup queries prepared in case natural language needs guidance

**Presentation Prep:**
- [ ] Set context: Industry pain points and business challenges
- [ ] Prepare persona introductions for each scenario
- [ ] Rehearse natural language questions (speak them, don't type cold)
- [ ] Have fallback SQL ready if Cortex Analyst misinterprets
- [ ] Prepare closing: Next steps and customer engagement path

**Demo Hygiene:**
- [ ] Clear browser cache and close unnecessary tabs
- [ ] Verify warehouse is running to avoid cold-start delay
- [ ] Have queries pre-staged in Snowsight tabs as backup
- [ ] Test screen sharing and resolution for readability
- [ ] Mute notifications and close chat applications

---

## Supporting Materials

**Included in Repository:**
- `README.md` - Comprehensive project overview and quick start guide
- `CORTEX_ANALYST.md` - Semantic view deployment and usage instructions
- `SEMANTIC_VIEWS.md` - Detailed semantic model documentation
- `requirements.*.md` - Product requirement documents for each scenario
- `deploy.sh` - Automated deployment script
- `run.sh` - Verification and testing script
- `semantic_views/*.yaml` - Semantic view model definitions

**Follow-Up Resources:**
- Snowflake Cortex documentation links
- SQL scripts for manual exploration
- Sample data generation code for customization
- Deployment logs for troubleshooting

---

## Questions & Discussion Topics

**Expected Questions:**
- *How long does deployment take?* ~5-10 minutes for full setup
- *Can this integrate with our existing weather data provider?* Yes, replace DIM_WEATHER_MODEL and FCT_WEATHER_FORECAST sources
- *What about real-time data?* Architecture supports streaming ingestion via Snowpipe
- *How accurate is Cortex Analyst?* Semantic views provide structural guidance; accuracy improves with verified queries and business context
- *What's the licensing cost?* Cortex Analyst is consumption-based; semantic views are included

**Discussion Topics:**
- Extending to customer-specific scenarios (renewable energy, utilities, mining)
- Integration patterns with existing systems (ERP, ETRM, CMMS, P6)
- Governance and data security for cross-functional access
- ML model integration for advanced predictive analytics
- Real-time alerting and workflow automation opportunities

---

## Call to Action

**For Prospects:**
- Schedule a workshop to map your specific weather risk use cases to this architecture
- Provide sample data for customized proof-of-concept
- Identify pilot scenario (projects, assets, or hedging) for 30-day trial

**For Customers:**
- Extend existing Snowflake implementation with Cortex Analyst semantic views
- Integrate weather data feeds into unified data platform
- Build cross-functional analytics COE to replicate this pattern across operations

**For Partners:**
- Leverage this demo as reference architecture for energy vertical offerings
- Customize semantic views with industry-specific terminology and KPIs
- Co-develop additional scenarios (renewables, utilities, midstream)

---

## Demo Credits & Acknowledgments

**Built With:**
- Snowflake Data Cloud
- Snowflake Cortex Analyst
- Semantic Views (YAML-based modeling)
- Snowflake CLI for deployment automation

**Data Sources:**
- Synthetic data generated using Snowflake generator functions
- Based on real-world energy industry scenarios and KPIs
- Weather patterns reflect actual US geographic and seasonal variations

**Version:** 1.0 (November 2024)

**Status:** Production-ready for demonstration and pilot deployments

---

## Contact & Next Steps

For additional information about this demo or to schedule a walkthrough:

- **Demo Repository:** `energy_weather_event/`
- **Deployment Time:** 5-10 minutes
- **Prerequisites:** Snowflake account with Cortex enabled
- **Support:** See README.md for troubleshooting and FAQ

**Ready to Get Started?**
```bash
./deploy.sh  # Creates all objects and loads sample data
./run.sh     # Verifies deployment
# Open Snowsight and start asking questions!
```

---

*This demo represents a strategic investment in understanding how AI-powered analytics can transform weather risk from a cost center to a competitive advantage across the energy value chain.*

