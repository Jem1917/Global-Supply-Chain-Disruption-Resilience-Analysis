# 📚 Data Dictionary

Complete reference guide for all columns in the Global Supply Chain Disruption dataset.

---

## Dataset Overview

- **Source:** Kaggle - "Global Supply Chain Disruption & Resilience Dataset"
- **Records:** 10,000 shipment entries
- **Time Period:** January 2024 - January 2026 (2 years)
- **File Format:** CSV (Comma-Separated Values)
- **File Size:** ~2.5 MB
- **Encoding:** UTF-8

---

## Table: `global_supply_chain_disruption_v1` (Original CSV)

This is the raw imported data before normalization.

| Column Name | Data Type | Description | Example Values | Constraints | Notes |
|-------------|-----------|-------------|----------------|-------------|-------|
| **Order_ID** | VARCHAR(50) | Unique identifier for each shipment | ORD_12345, ORD_67890 | UNIQUE, NOT NULL | Primary key in source data |
| **Order_Date** | DATE | Date when shipment was booked | 2024-01-15, 2025-06-22 | NOT NULL | Format: M/D/YYYY in CSV, converted to MySQL DATE |
| **Origin_City** | VARCHAR(100) | Departure/loading location | Shanghai, CN; Hamburg, DE | NOT NULL | Includes country code |
| **Destination_City** | VARCHAR(100) | Arrival/unloading location | Los Angeles, US; Rotterdam, NL | NOT NULL | Includes country code |
| **Route_Type** | VARCHAR(50) | Trade corridor classification | Pacific, Atlantic, Suez, Commodity, Intra-Asia | NOT NULL | 5 unique values |
| **Transportation_Mode** | VARCHAR(20) | Primary shipping method | Sea, Air | NOT NULL | 2 unique values |
| **Product_Category** | VARCHAR(100) | Type of cargo being shipped | Electronics, Pharmaceuticals, Auto Parts | NOT NULL | 7 unique categories |
| **Base_Lead_Time_Days** | INT | Expected transit time (SLA) | 6, 10, 16, 22, 29 | > 0 | Baseline for delay calculation |
| **Actual_Lead_Time_Days** | INT | Realized transit time | 6, 12, 18, 24, 35 | >= Base_Lead_Time | Includes delays |
| **Delay_Days** | INT | Difference (Actual - Base) | 0, 2, 5, 10, 15 | >= 0 | Key performance metric |
| **Delivery_Status** | VARCHAR(20) | On-time vs late classification | On Time, Late | NOT NULL | Binary outcome |
| **Disruption_Event** | VARCHAR(100) | Type of incident encountered | Port Congestion, Severe Weather, Geopolitical Conflict, None | NULL allowed | NULL = no disruption |
| **Geopolitical_Risk_Index** | DECIMAL(3,2) | Political instability score | 0.00 - 1.00 | 0 <= value <= 1 | Higher = more unstable |
| **Weather_Severity_Index** | DECIMAL(4,2) | Weather impact severity | 0.00 - 10.00 | 0 <= value <= 10 | Higher = worse conditions |
| **Shipping_Cost_USD** | DECIMAL(10,2) | Freight charges in USD | 10450.00, 53120.00 | > 0 | Does NOT include insurance/customs |
| **Mitigation_Action_Taken** | VARCHAR(100) | Response strategy deployed | Re-routing, Expedited Air Freight, Standard Shipping | NULL allowed | NULL = no action needed |

---

## Normalized Tables (After Transformation)

### Table: `routes`

Stores unique route master data.

| Column | Type | Key | Description | Sample Values |
|--------|------|-----|-------------|---------------|
| **route_id** | INT | PK | Auto-incrementing route identifier | 1, 2, 3, 4, 5 |
| **origin_city** | VARCHAR(100) | | Departure location | Shanghai, CN |
| **destination_city** | VARCHAR(100) | | Arrival location | Los Angeles, US |
| **route_type** | VARCHAR(50) | | Trade corridor | Pacific, Atlantic, Suez |
| **base_lead_time_days** | INT | | Average expected transit time | 16, 22, 29 |

**Unique Constraint:** `(origin_city, destination_city)`  
**Record Count:** 5 routes

**Route Details:**
1. Shanghai, CN → Los Angeles, US (Pacific) - 16 days
2. Hamburg, DE → New York, US (Atlantic) - 10 days
3. Santos, BR → Shanghai, CN (Commodity) - 29 days
4. Shenzhen, CN → Rotterdam, NL (Suez) - 23 days
5. Mumbai, IN → Felixstowe, UK (Suez) - 21 days
6. Tokyo, JP → Singapore, SG (Intra-Asia) - 6 days

---

### Table: `products`

Stores product category master data.

| Column | Type | Key | Description | Sample Values |
|--------|------|-----|-------------|---------------|
| **product_id** | INT | PK | Auto-incrementing product identifier | 1, 2, 3, ..., 7 |
| **product_category** | VARCHAR(100) | UNIQUE | Type of cargo | Electronics, Pharmaceuticals |

**Record Count:** 7 categories

**Product Categories:**
1. Auto Parts
2. Consumer Electronics
3. Perishable Foods
4. Pharmaceuticals
5. Raw Materials
6. Semiconductors
7. Textiles

---

### Table: `shipments` (Fact Table)

Core transactional data linking routes, products, and outcomes.

| Column | Type | Key | Description | Sample Values |
|--------|------|-----|-------------|---------------|
| **shipment_id** | INT | PK | Auto-incrementing shipment identifier | 1, 2, 3, ..., 10000 |
| **order_id** | VARCHAR(50) | UNIQUE | External order reference | ORD_12345 |
| **order_date** | DATE | INDEX | Booking date | 2024-01-15 |
| **route_id** | INT | FK | References routes(route_id) | 1, 2, 3 |
| **transportation_mode** | VARCHAR(20) | | Sea or Air | Sea, Air |
| **product_id** | INT | FK | References products(product_id) | 1, 2, 3 |
| **actual_lead_time_days** | INT | | Realized transit time | 18, 24, 35 |
| **delivery_status** | VARCHAR(20) | INDEX | On Time or Late | On Time, Late |
| **shipping_cost_usd** | DECIMAL(10,2) | | Freight charges | 10450.00 |

**Foreign Keys:**
- `route_id` → `routes(route_id)`
- `product_id` → `products(product_id)`

**Indexes:**
- `idx_order_date` on `order_date`
- `idx_delivery_status` on `delivery_status`

**Record Count:** 10,000 shipments

---

### Table: `disruptions`

Stores disruption events and risk metrics (1:1 with shipments).

| Column | Type | Key | Description | Sample Values |
|--------|------|-----|-------------|---------------|
| **disruption_id** | INT | PK | Auto-incrementing disruption identifier | 1, 2, 3, ..., 10000 |
| **shipment_id** | INT | FK | References shipments(shipment_id) | 1, 2, 3 |
| **disruption_event** | VARCHAR(100) | INDEX | Type of incident | Port Congestion, Severe Weather |
| **geopolitical_risk_index** | DECIMAL(3,2) | | Political instability (0-1) | 0.45, 0.62, 0.78 |
| **weather_severity_index** | DECIMAL(4,2) | | Weather impact (0-10) | 2.5, 5.8, 7.3 |
| **delay_days** | INT | | Actual delay incurred | 0, 2, 5, 10 |

**Foreign Keys:**
- `shipment_id` → `shipments(shipment_id)`

**Indexes:**
- `idx_disruption_event` on `disruption_event`

**Record Count:** 10,000 records (1 per shipment)

**Disruption Event Types:**
- None (87.3% of shipments)
- Port Congestion (57.3% of disrupted)
- Geopolitical Conflict (Route Diversion) (52.1% of disrupted)
- Severe Weather (Typhoon/Storm) (17.3% of disrupted)

---

### Table: `mitigations`

Stores mitigation actions taken (1:1 with shipments).

| Column | Type | Key | Description | Sample Values |
|--------|------|-----|-------------|---------------|
| **mitigation_id** | INT | PK | Auto-incrementing mitigation identifier | 1, 2, 3, ..., 10000 |
| **shipment_id** | INT | FK | References shipments(shipment_id) | 1, 2, 3 |
| **mitigation_action_taken** | VARCHAR(100) | | Response strategy | Re-routing, Expedited Air Freight |

**Foreign Keys:**
- `shipment_id` → `shipments(shipment_id)`

**Record Count:** 10,000 records (1 per shipment)

**Mitigation Actions:**
- Standard Shipping (92.83% of shipments)
- Re-routing (3.68%)
- Expedited Air Freight (3.49%)

---

## Data Quality Notes

### Missing Values
- **None in critical fields:** All shipments have complete data for order_id, dates, routes, costs
- **NULL values allowed:**
  - `disruption_event`: NULL when no disruption occurred (87.3% of records)
  - `mitigation_action_taken`: NULL when no action needed

### Data Ranges & Validation

| Field | Min | Max | Mean | Std Dev |
|-------|-----|-----|------|---------|
| **Base_Lead_Time_Days** | 6 | 29 | 18.2 | 7.3 |
| **Actual_Lead_Time_Days** | 6 | 45 | 18.7 | 7.5 |
| **Delay_Days** | 0 | 20 | 0.95 | 2.8 |
| **Geopolitical_Risk_Index** | 0.00 | 1.00 | 0.49 | 0.12 |
| **Weather_Severity_Index** | 0.00 | 10.00 | 4.97 | 1.2 |
| **Shipping_Cost_USD** | 1,800 | 54,000 | 11,437 | 8,500 |

### Data Integrity Checks Passed
✅ No orphaned records (all FKs resolve)  
✅ No duplicate Order_IDs  
✅ Dates are sequential and realistic  
✅ Delay_Days = Actual_Lead_Time - Base_Lead_Time  
✅ Delivery_Status matches delay logic (Late if Delay_Days > 0)  
✅ No negative values where inappropriate  

---

## Calculated Fields (Derived in Queries)

These fields are computed during SQL analysis, not stored in tables:

| Field Name | Calculation | Example | Used In |
|------------|-------------|---------|---------|
| **On-Time Percentage** | `(On Time count / Total) × 100` | 87.1% | Multiple queries |
| **Disruption Rate** | `(Disrupted / Total) × 100` | 12.7% | Query 4 |
| **Combined Risk Score** | `(geo_risk × 10) + weather_risk` | 9.91 | Query 7 |
| **Efficiency Percentage** | `(Base Lead Time / Actual) × 100` | 97.06% | Query 11 |
| **Cost Per Delay Day** | `Shipping Cost / Delay Days` | $305/day | Query 13 |
| **Success Rate** | `(On Time / Total Actions) × 100` | 93.66% | Query 17 |

---

## Business Rules & Assumptions

### Delivery Status Logic
```sql
-- A shipment is "Late" if Actual_Lead_Time > Base_Lead_Time
CASE 
    WHEN Actual_Lead_Time_Days > Base_Lead_Time_Days THEN 'Late'
    ELSE 'On Time'
END
```

### Risk Classification Thresholds

**Geopolitical Risk:**
- Low Risk: 0.00 - 0.30
- Medium Risk: 0.30 - 0.60
- High Risk: 0.60 - 1.00

**Weather Severity:**
- Mild: 0 - 3
- Moderate: 3 - 6
- Severe: 6 - 10

**Combined Risk Score:**
- Low Risk: 0 - 5.0
- Medium Risk: 5.0 - 8.0
- High Risk: 8.0+

### Cost Assumptions
- **Shipping_Cost_USD** includes:
  - Base freight charges
  - Fuel surcharges
  - Handling fees
  
- **NOT included:**
  - Customs duties
  - Insurance premiums
  - Demurrage/detention fees
  - Last-mile delivery

### Delay Cost Estimation
**Assumed penalty:** $100 per delay day (used in KPI calculations)

---

## Data Lineage

### Source → Raw Import
```
Kaggle CSV Download
    ↓
global_supply_chain_disruption_v1 (staging table)
    ↓ (data validation & cleansing)
```

### Raw → Normalized Tables
```
global_supply_chain_disruption_v1
    ↓ (normalization scripts)
    ├─→ routes (5 records)
    ├─→ products (7 records)
    ├─→ shipments (10,000 records)
    ├─→ disruptions (10,000 records)
    └─→ mitigations (10,000 records)
```

### Normalized → Views (for BI)
```
Normalized Tables
    ↓ (aggregation queries)
    ├─→ v_monthly_trends (view)
    └─→ v_route_performance (view)
```

---

## Usage Examples

### Filtering by Date Range
```sql
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
```

### Filtering by Risk Level
```sql
WHERE geopolitical_risk_index > 0.6  -- High risk only
```

### Excluding "No Disruption" Records
```sql
WHERE disruption_event IS NOT NULL
```

### Finding High-Value Shipments
```sql
WHERE shipping_cost_usd > 20000
```

---

## Schema Evolution Notes

**Version 1.0 (Current):**
- Initial normalized schema with 5 tables
- Supports 10,000 records

**Future Enhancements (Planned):**
- Add `carriers` table for vendor analysis
- Add `insurance_claims` table for loss tracking
- Add `customer_feedback` table for satisfaction scores
- Implement time-series partitioning for scalability

---

## Export Formats

### For Power BI / Tableau
Use the pre-built views:
```sql
SELECT * FROM v_monthly_trends;
SELECT * FROM v_route_performance;
```

### For Excel Analysis
Export query results as CSV:
```sql
SELECT ... INTO OUTFILE '/path/to/file.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

---

## Metadata Summary

| Attribute | Value |
|-----------|-------|
| Total Tables | 5 (normalized) + 1 (staging) |
| Total Columns | 36 across all tables |
| Total Records | 45,005 (10K per table + 5 routes + 7 products) |
| Storage Size | ~5 MB (estimated) |
| Query Complexity | Beginner to Advanced |
| BI Tool Compatible | Yes (Power BI, Tableau, Excel) |

---

## Contact for Questions

If you need clarification on any column definitions or data quality issues, please contact:

**[Your Name]**  
📧 your.email@example.com  
💼 LinkedIn: [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)

---

**Last Updated:** February 2026  
**Version:** 1.0
