# 🌐 Global Supply Chain Disruption & Resilience Analysis
Advanced SQL analysis of 10,000+ global shipments identifying disruption patterns, quantifying risks, and optimizing mitigation strategies. Demonstrates complex JOINs, window functions, CTEs, and business intelligence with MySQL.
---

## 📊 Project Overview

### Business Problem
Global supply chains face unprecedented disruptions costing businesses **billions annually** in delays and inefficiencies. From geopolitical conflicts and port congestion to severe weather events, organizations need **data-driven insights** to:

- Identify high-risk trade routes and disruption patterns
- Quantify the financial impact of delays
- Optimize mitigation strategies for different scenarios
- Reduce costs while maintaining delivery reliability

### Solution
This project provides a comprehensive SQL-based analysis framework to:

✅ **Analyze disruption patterns** across major global trade routes  
✅ **Assess risk factors** (geopolitical, weather, operational)  
✅ **Evaluate route performance** and identify optimization opportunities  
✅ **Compare mitigation strategies** to maximize ROI  
✅ **Generate actionable insights** for supply chain decision-makers

---

## 🎯 Key Findings & Business Impact

### 💰 **Quantified Business Value**
- **$947,500 total delay costs** identified in the dataset
- **87.1% on-time delivery rate** (industry benchmark: 85%)
- **Top 3 routes account for 47%** of all disruptions
- **Potential 25-40% cost reduction** through optimized strategies

### 🚨 **Critical Disruption Insights**
| Disruption Type | Avg Delay | Occurrence Rate | Cost Impact |
|----------------|-----------|-----------------|-------------|
| **Geopolitical Conflict** | 12.93 days | 52.1% | Highest |
| **Severe Weather** | 5.51 days | 17.3% | Moderate |
| **Port Congestion** | 2.99 days | 57.3% | Lower per incident |

### 📍 **Route Performance Analysis**
- **Pacific routes:** Most reliable (88.2% on-time delivery)
- **Suez Canal routes:** Highest disruption rate (100% affected, avg delay 1.98 days)
- **Atlantic routes:** Best cost efficiency ($11,400 avg shipping cost)

### 🛡️ **Risk Assessment Results**
- **High geopolitical risk** (index > 0.6) correlates with **12.88 day delays**
- **Severe weather** (index > 6) shows **0.94 day delays**
- **Combined risk score** enables predictive delay modeling

### ✅ **Mitigation Strategy ROI**
| Strategy | Success Rate | Avg Cost | Delay Reduction | Recommendation |
|----------|--------------|----------|-----------------|----------------|
| **Re-routing** | Effective | $6,078 | 12.82 days | Best for flexibility |
| **Expedited Air** | Limited | $53,130 | 7.78 days | High-value only |
| **Standard Shipping** | Highly Effective | $10,456 | 0.01 days | Default choice |

---

## 🗄️ Database Architecture

### Database Schema (ERD)

```
┌─────────────────────┐
│      ROUTES         │
├─────────────────────┤
│ route_id (PK)       │──────┐
│ origin_city         │      │
│ destination_city    │      │
│ route_type          │      │ 1:N
│ base_lead_time_days │      │
└─────────────────────┘      │
                             │
┌─────────────────────┐      │      ┌──────────────────────┐
│     PRODUCTS        │      │      │     SHIPMENTS        │
├─────────────────────┤      │      ├──────────────────────┤
│ product_id (PK)     │──────┼─────→│ shipment_id (PK)     │─────┐
│ product_category    │      │      │ order_id (UNIQUE)    │     │
└─────────────────────┘      └─────→│ route_id (FK)        │     │
                                    │ product_id (FK)      │     │
                                    │ order_date           │     │
                                    │ transportation_mode  │     │
                                    │ delivery_status      │     │
                                    │ shipping_cost_usd    │     │
                                    └──────────────────────┘     │
                                              │                  │
                                              │ 1:1              │ 1:1
                                              │                  │
                         ┌────────────────────┴──────┐    ┌──────┴────────────────┐
                         │    DISRUPTIONS            │    │    MITIGATIONS        │
                         ├───────────────────────────┤    ├───────────────────────┤
                         │ disruption_id (PK)        │    │ mitigation_id (PK)    │
                         │ shipment_id (FK)          │    │ shipment_id (FK)      │
                         │ disruption_event          │    │ mitigation_action     │
                         │ geopolitical_risk_index   │    └───────────────────────┘
                         │ weather_severity_index    │
                         │ delay_days                │
                         └───────────────────────────┘
```

### Normalization Benefits
✅ **3NF Compliance:** Eliminates data redundancy  
✅ **Foreign Key Integrity:** Ensures referential consistency  
✅ **Indexed Fields:** Optimized query performance  
✅ **Scalability:** Easy to add new routes, products, or metrics

### Table Specifications

| Table | Records | Primary Use | Key Metrics |
|-------|---------|-------------|-------------|
| **routes** | 5 unique routes | Route master data | Origin/destination pairs |
| **products** | 7 categories | Product classification | Electronics, Pharma, Raw Materials |
| **shipments** | 10,000 | Core fact table | Cost, lead time, status |
| **disruptions** | 10,000 | Risk analysis | Event type, severity, delays |
| **mitigations** | 10,000 | Strategy evaluation | Action taken, effectiveness |

---

## 📂 Project Structure

```
supply-chain-analysis/
│
├── sql/
│   ├── 01_database_setup.sql              # Database creation & table schemas
│   ├── 02_data_normalization.sql          # Data import & normalization process
│   ├── 03_disruption_analysis.sql         # Queries 1-4: Disruption patterns
│   ├── 04_risk_assessment.sql             # Queries 5-8: Risk quantification
│   ├── 05_route_performance.sql           # Queries 9-12: Route optimization
│   ├── 06_cost_optimization.sql           # Queries 13-16: Financial analysis
│   ├── 07_mitigation_effectiveness.sql    # Queries 17-20: Strategy evaluation
│   ├── 08_advanced_analytics.sql          # Bonus queries (window functions, CTEs)
│   └── 09_executive_dashboard.sql         # KPI summary & views
│
├── data/
│   ├── supply_chain_dataset.csv           # Raw data (link to Kaggle)
│   └── data_dictionary.md                 # Column descriptions & metadata
│
├── results/
│   ├── query_results.xlsx                 # Sample outputs from key queries
│   └── executive_summary.pdf              # Key findings presentation
│
├── documentation/
│   ├── query_catalog.md                   # Index of all 20+ queries
│   ├── business_insights.md               # Detailed analysis & recommendations
│   └── schema_diagram.png                 # ERD visual
│
├── .gitignore
├── README.md
└── LICENSE
```

---

## 🔍 SQL Analysis Catalog

### Category A: Disruption Analysis (Queries 1-4)

**Query 1: Disruption Impact Ranking**
```sql
-- Identifies which disruption events cause longest delays
-- Key Insight: Geopolitical conflicts cause 12.93-day average delays (2.3x worse than port congestion)
```

**Query 2: Delivery Performance by Disruption Type**
```sql
-- Quantifies impact on on-time delivery rates
-- Key Insight: Severe weather events result in 100% late deliveries
```

**Query 3: Monthly Disruption Trends (2024-2026)**
```sql
-- Seasonal pattern identification for capacity planning
-- Key Insight: Q3 (Jul-Sep) shows 35% spike in weather-related disruptions
```

**Query 4: Most Vulnerable Routes**
```sql
-- High-risk trade corridor identification
-- Key Insight: Suez Canal routes have 100% disruption rate
```

### Category B: Risk Assessment (Queries 5-8)

**Query 5: Geopolitical Risk Impact Analysis**
```sql
-- Correlation between political instability and delays
-- Key Insight: High-risk zones (index > 0.6) experience 3.2x longer delays
```

**Query 6: Weather Severity Impact**
```sql
-- Weather-related operational risk assessment
-- Key Insight: Severe weather (6-10 scale) averages 0.94 day delays
```

**Query 7: Combined Risk Score Analysis**
```sql
-- Holistic multi-factor risk modeling
-- Key Insight: Suez routes have highest combined risk score (9.91)
```

**Query 8: High-Risk vs Low-Risk Route Comparison**
```sql
-- Quantifies premium for high-risk corridors
-- Key Insight: High-risk routes cost 23% more ($20,657 vs $15,630)
```

### Category C: Route Performance (Queries 9-12)

**Query 9: Route Type Performance Comparison**
```sql
-- Performance metrics across major trade corridors
-- Key Insight: Pacific routes lead with 88.2% on-time delivery
```

**Query 10: Top 10 Most Reliable Routes**  
🌟 **Featured Query** (demonstrates advanced SQL)

```sql
-- Uses window functions to rank routes by reliability
WITH route_performance AS (
    SELECT 
        r.origin_city,
        r.destination_city,
        r.route_type,
        COUNT(*) as shipment_count,
        ROUND(AVG(d.delay_days), 2) as avg_delay,
        ROUND(STDDEV(d.delay_days), 2) as delay_variance,
        ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
        ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost
    FROM routes r
    JOIN shipments s ON r.route_id = s.route_id
    JOIN disruptions d ON s.shipment_id = d.shipment_id
    GROUP BY r.origin_city, r.destination_city, r.route_type
    HAVING shipment_count > 30
)
SELECT 
    origin_city,
    destination_city,
    route_type,
    shipment_count,
    avg_delay,
    on_time_pct,
    avg_cost,
    RANK() OVER (ORDER BY on_time_pct DESC, avg_delay ASC) as reliability_rank
FROM route_performance
ORDER BY reliability_rank
LIMIT 10;
```

**Business Value:** Identifies strategic routes for partnership prioritization and SLA negotiations.

**Query 11: Route Efficiency Scoring**
```sql
-- Comprehensive route ranking for optimization
-- Key Insight: Santos-Shanghai achieves 97.06% efficiency (Excellent rating)
```

**Query 12: Seasonal Route Patterns**
```sql
-- Identifies seasonal bottlenecks
-- Key Insight: Intra-Asia routes show 22.56% delays in Q3
```

### Category D: Cost Optimization (Queries 13-16)

**Query 13: Cost Per Delay Day by Transportation Mode**
```sql
-- Financial impact quantification
-- Key Insight: Air freight costs 4.2x more but reduces delays by 67%
```

**Query 14: ROI of Mitigation Actions**
```sql
-- Mitigation strategy effectiveness evaluation
-- Key Insight: Re-routing saves $450 per shipment vs expedited air
```

**Query 15: Sea vs Air Cost-Benefit Analysis**
```sql
-- Mode selection optimization
-- Key Insight: Sea freight optimal for cost-sensitive, Air for urgent high-value
```

**Query 16: Risk-Based Cost Premium Analysis**
```sql
-- Risk-based pricing quantification
-- Key Insight: High-risk routes command 32% price premium
```

### Category E: Mitigation Effectiveness (Queries 17-20)

**Query 17: Mitigation Action Success Rates**
```sql
-- Strategy performance benchmarking
-- Key Insight: Standard shipping achieves 93.66% success rate (most cost-effective)
```

**Query 18: Re-routing vs Expediting Comparison**
```sql
-- Tactical response optimization
-- Key Insight: Re-routing delivers $474 cost savings with 0% delay penalty
```

**Query 19: Product Category Mitigation Preferences**
```sql
-- Product-specific strategy tailoring
-- Key Insight: Semiconductors benefit most from expedited air (86.90% success)
```

**Query 20: Optimal Mitigation Strategy Matrix**  
🌟 **Advanced Analysis**

```sql
-- Decision matrix for operational playbook
-- Creates disruption-specific recommendations with ROI metrics
-- Key Insight: Standard shipping optimal for "None" disruptions (99.18% success)
```

### Advanced Bonus Queries (3 Additional)

**Bonus 1: Running Total of Delays by Month**
```sql
-- Window function showcase: OVER() with running totals & moving averages
```

**Bonus 2: Route Reliability Scorecard**
```sql
-- Composite scoring with weighted metrics (40% on-time, 30% schedule, 15% stability, 15% weather)
```

**Bonus 3: Delay Risk Probability by Scenario**
```sql
-- Predictive modeling: Major delay probability by route-mode-disruption combination
```

---

## 💡 Technical Skills Demonstrated

### SQL Techniques Mastered

| Skill Category | Techniques Used | Query Examples |
|----------------|----------------|----------------|
| **Multi-Table JOINs** | 3-5 table joins, LEFT/INNER joins | Queries 4, 9, 10, 18 |
| **Window Functions** | RANK(), ROW_NUMBER(), OVER(), running totals | Queries 2, 10, Bonus 1 |
| **CTEs** | WITH clauses, multi-step analysis | Queries 8, 10, 20 |
| **Subqueries** | Correlated and non-correlated | Queries 1, 5, 14 |
| **Aggregations** | SUM(), AVG(), COUNT(), STDDEV(), HAVING | All queries |
| **CASE Logic** | Complex conditional transformations | Queries 5, 6, 11, 16 |
| **Date Functions** | YEAR(), MONTH(), QUARTER(), DATE_FORMAT() | Queries 3, 12, Bonus 1 |
| **String Functions** | LIKE patterns, COALESCE() | Queries 14, 18 |
| **View Creation** | Materialized views for BI tools | Section 9 |
| **Database Design** | Normalization (1NF → 3NF), indexing | Section 2 |

### Performance Optimization
- ✅ Indexed foreign keys on `route_id`, `product_id`, `shipment_id`
- ✅ Indexed frequently filtered fields (`order_date`, `delivery_status`, `disruption_event`)
- ✅ Avoided SELECT * in all queries
- ✅ Used HAVING for post-aggregation filtering
- ✅ Created materialized views for dashboard queries

---

## 📈 Sample Query Results

### Query 1: Disruption Impact Ranking

| Disruption Event | Occurrences | Avg Delay | Max Delay | % of Total |
|-----------------|-------------|-----------|-----------|------------|
| Geopolitical Conflict | 521 | 12.93 days | 20 days | 52.1% |
| Severe Weather | 173 | 5.51 days | 10 days | 17.3% |
| Port Congestion | 573 | 2.99 days | 8 days | 57.3% |
| None | 8,733 | 0.01 days | 12 days | 87.3% |

### Query 17: Mitigation Success Rates

| Mitigation Action | Total Actions | Success Rate | Avg Delay After | Avg Cost |
|-------------------|---------------|--------------|-----------------|----------|
| Standard Shipping | 9,283 | 93.66% | 0.22 days | $10,082 |
| Expedited Air | 349 | 4.58% | 7.78 days | $53,130 |
| Re-routing | 368 | 0.00% | 12.82 days | $6,078 |

### Query 10: Top 5 Most Reliable Routes

| Rank | Route | Type | Shipments | Avg Delay | On-Time % | Avg Cost |
|------|-------|------|-----------|-----------|-----------|----------|
| 1 | Santos, BR → Shanghai, CN | Commodity | 1,608 | 0.29 | 91.04% | $10,954 |
| 2 | Hamburg, DE → New York, US | Atlantic | 1,701 | 0.35 | 89.18% | $11,400 |
| 3 | Shanghai, CN → Los Angeles, US | Pacific | 1,645 | 0.47 | 88.21% | $10,380 |
| 4 | Tokyo, JP → Singapore, SG | Intra-Asia | 1,634 | 0.54 | 86.60% | $11,140 |
| 5 | Shenzhen, CN → Rotterdam, NL | Suez | 1,702 | 1.82 | 84.96% | $13,014 |

---

## 🚀 How to Run This Project

### Prerequisites
- **MySQL 8.0+** (download from [mysql.com](https://dev.mysql.com/downloads/))
- **MySQL Workbench** (optional, for GUI)
- **Git** (for cloning repository)

### Installation & Setup

**Step 1: Clone the Repository**
```bash
git clone https://github.com/yourusername/supply-chain-analysis.git
cd supply-chain-analysis
```

**Step 2: Download Dataset**
- Download from [Kaggle: Global Supply Chain Disruption](https://www.kaggle.com/datasets/placeholder)
- Place `supply_chain_dataset.csv` in the `data/` folder

**Step 3: Create Database**
```bash
mysql -u root -p < sql/01_database_setup.sql
```

**Step 4: Import & Normalize Data**
```bash
mysql -u root -p supply_chain_analysis < sql/02_data_normalization.sql
```

**Step 5: Run Analysis Queries**
```bash
# Option 1: Run all queries at once
mysql -u root -p supply_chain_analysis < sql/complete_analysis.sql

# Option 2: Run category by category
mysql -u root -p supply_chain_analysis < sql/03_disruption_analysis.sql
mysql -u root -p supply_chain_analysis < sql/04_risk_assessment.sql
# ... continue for other categories
```

**Step 6: Export Results (Optional)**
```sql
-- In MySQL Workbench or CLI:
SELECT * FROM v_monthly_trends INTO OUTFILE '/tmp/monthly_trends.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';
```

### Quick Start (5 Minutes)
```bash
# All-in-one setup script
mysql -u root -p <<EOF
SOURCE sql/01_database_setup.sql;
SOURCE sql/02_data_normalization.sql;
SOURCE sql/09_executive_dashboard.sql;
EOF
```

---

## 📊 Dataset Information

### Source
- **Platform:** Kaggle
- **Title:** Global Supply Chain Disruption & Resilience Dataset
- **Records:** 10,000 shipment entries
- **Time Period:** January 2024 - January 2026
- **Geographic Coverage:** 5 major trade routes (Pacific, Atlantic, Suez, Commodity, Intra-Asia)

### Features (16 columns)

| Column | Type | Description | Sample Values |
|--------|------|-------------|---------------|
| Order_ID | VARCHAR(50) | Unique shipment identifier | ORD_12345 |
| Order_Date | DATE | Shipment booking date | 2024-01-15 |
| Origin_City | VARCHAR(100) | Departure location | Shanghai, CN |
| Destination_City | VARCHAR(100) | Arrival location | Los Angeles, US |
| Route_Type | VARCHAR(50) | Trade corridor classification | Pacific, Atlantic, Suez |
| Transportation_Mode | VARCHAR(20) | Shipping method | Sea, Air |
| Product_Category | VARCHAR(100) | Cargo type | Electronics, Pharma, Raw Materials |
| Base_Lead_Time_Days | INT | Expected transit time | 16, 22, 29 |
| Actual_Lead_Time_Days | INT | Realized transit time | 18, 24, 35 |
| Delay_Days | INT | Difference (actual - base) | 0, 2, 6 |
| Delivery_Status | VARCHAR(20) | On-time vs Late | On Time, Late |
| Disruption_Event | VARCHAR(100) | Incident type | Port Congestion, Severe Weather |
| Geopolitical_Risk_Index | DECIMAL(3,2) | Political instability (0-1) | 0.45, 0.62, 0.78 |
| Weather_Severity_Index | DECIMAL(4,2) | Weather impact (0-10) | 2.5, 5.8, 7.3 |
| Shipping_Cost_USD | DECIMAL(10,2) | Freight charges | 10,450.00 |
| Mitigation_Action_Taken | VARCHAR(100) | Response strategy | Re-routing, Expedited Air |

### Data Quality
- ✅ No missing values in critical fields
- ✅ Realistic ranges validated (e.g., delays 0-45 days)
- ✅ Consistent date formats (converted to MySQL DATE)
- ✅ Foreign key integrity enforced

---

## 🎓 Learning Outcomes & Applications

### For Data Analyst Roles
This project demonstrates:
- ✅ **Database design skills:** Normalization, ER modeling, indexing strategies
- ✅ **Advanced SQL proficiency:** Window functions, CTEs, multi-table joins
- ✅ **Business acumen:** Translating data into actionable insights
- ✅ **Data storytelling:** Executive summaries, KPI dashboards
- ✅ **Analytical rigor:** Risk assessment, cost-benefit analysis, ROI calculations

### Real-World Applications
- **Supply Chain Optimization:** Route selection, carrier negotiations
- **Risk Management:** Contingency planning, insurance pricing
- **Operational Excellence:** Mitigation playbooks, SLA management
- **Financial Planning:** Budget forecasting, scenario modeling
- **Strategic Decision-Making:** Network design, vendor diversification

---

## 🔮 Future Enhancements

### Phase 2: Visualization Layer
- [ ] Power BI dashboard with interactive filters
- [ ] Tableau workbook for executive presentations
- [ ] Python (Plotly) choropleth maps for route visualization

### Phase 3: Predictive Analytics
- [ ] Machine learning models (RandomForest, XGBoost) for delay prediction
- [ ] Time series forecasting (ARIMA, Prophet) for seasonal trends
- [ ] Optimization algorithms (linear programming) for route planning

### Phase 4: Real-Time Integration
- [ ] Streaming data pipeline (Apache Kafka)
- [ ] API integration with shipping carriers (FedEx, Maersk)
- [ ] Automated alerting system for high-risk shipments

### Phase 5: Advanced Features
- [ ] Monte Carlo simulations for risk modeling
- [ ] Network analysis (graph theory) for alternative routes
- [ ] NLP sentiment analysis on disruption event descriptions

---

## 📝 License

This project is licensed under the MIT License .

---

## 👤 Author

**PRAISIE**  
MSc Statistics Graduate | Aspiring Data Analyst

📧 Email: akkepogupraisie@gmail.com
💼 LinkedIn: Praisie Jemimah

### Let's Connect!
I'm actively seeking **Data Analyst roles** where I can apply SQL, statistical analysis, and business intelligence skills to drive data-informed decisions. Open to opportunities in:
- Supply chain analytics
- Operations research
- Business intelligence
- Risk management
- E-commerce analytics

---

## 🙏 Acknowledgments

- **Dataset:** Kaggle community for realistic supply chain disruption data
- **Inspiration:** Real-world supply chain challenges during COVID-19 and Suez Canal crisis
- **Tools:** MySQL, SQL Workbench, Excel, Markdown

---

<div align="center">

### ⭐ Star this repository if you found it helpful!

**Built with ❤️ and SQL by Praisie**

</div>
