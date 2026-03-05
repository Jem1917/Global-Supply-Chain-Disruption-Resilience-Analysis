-- ═══════════════════════════════════════════════════════════════════════════
--           GLOBAL SUPPLY CHAIN DISRUPTION & RESILIENCE ANALYSIS
--                          MySQL PROJECT
-- ═══════════════════════════════════════════════════════════════════════════
-- Author: A S PRAISIE JEMIMAH
-- MSc Statistics Graduate
-- Date: January 2026
-- 
-- Business Objective: Analyze global supply chain disruptions to identify
-- patterns, quantify risks, and evaluate mitigation strategies for optimal
-- logistics operations and cost reduction.
-- 
-- Dataset: 10,000 shipment records across major global trade routes
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 1: DATABASE SETUP & DATA LOADING
-- ═══════════════════════════════════════════════════════════════════════════

-- Create database
CREATE DATABASE supply_chain_analysis;
USE supply_chain_analysis;
select * from global_supply_chain_disruption_v1;
-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 2: TABLE NORMALIZATION (Best Practice)
-- ═══════════════════════════════════════════════════════════════════════════
-- We'll normalize the single CSV into 5 related tables to showcase JOIN skills

-- Table 1: Routes Master Table
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_city VARCHAR(100) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    route_type VARCHAR(50) NOT NULL,
    base_lead_time_days INT NOT NULL,
    UNIQUE KEY unique_route (origin_city, destination_city)
);
drop table routes;
select * from routes;


-- Table 2: Products Master Table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_category VARCHAR(100) NOT NULL UNIQUE
);
drop table products;
select * from products;

-- Table 3: Shipments Fact Table
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) UNIQUE NOT NULL,
    order_date DATE NOT NULL,
    route_id INT NOT NULL,
    transportation_mode VARCHAR(20) NOT NULL,
    product_id INT NOT NULL,
    actual_lead_time_days INT NOT NULL,
    delivery_status VARCHAR(20) NOT NULL,
    shipping_cost_usd DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order_date (order_date),
    INDEX idx_delivery_status (delivery_status)
);
drop table shipments;
select * from shipments;

-- Table 4: Disruptions Table
CREATE TABLE disruptions (
    disruption_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    disruption_event VARCHAR(100),
    geopolitical_risk_index DECIMAL(3, 2),
    weather_severity_index DECIMAL(4, 2),
    delay_days INT NOT NULL,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    INDEX idx_disruption_event (disruption_event)
);
select * from disruptions;
drop table disruptions;


-- Table 5: Mitigations Table
CREATE TABLE mitigations (
    mitigation_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    mitigation_action_taken VARCHAR(100),
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);
drop table mitigations;
select * from mitigations;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 3: DATA IMPORT FROM CSV
-- ═══════════════════════════════════════════════════════════════════════════

-- First, create a temporary staging table to load the raw CSV
CREATE TABLE staging_shipments (
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Origin_City VARCHAR(100),
    Destination_City VARCHAR(100),
    Route_Type VARCHAR(50),
    Transportation_Mode VARCHAR(20),
    Product_Category VARCHAR(100),
    Base_Lead_Time_Days INT,
    Actual_Lead_Time_Days INT,
    Delay_Days INT,
    Delivery_Status VARCHAR(20),
    Disruption_Event VARCHAR(100),
    Geopolitical_Risk_Index DECIMAL(3, 2),
    Weather_Severity_Index DECIMAL(4, 2),
    Shipping_Cost_USD DECIMAL(10, 2),
    Mitigation_Action_Taken VARCHAR(100)
);

drop table staging_shipments;
-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 4: POPULATE NORMALIZED TABLES
-- ═══════════════════════════════════════════════════════════════════════════

-- Populate routes table
-- Use AVG for base_lead_time in case of multiple values for same route
INSERT INTO routes (origin_city, destination_city, route_type, base_lead_time_days)
SELECT 
    Origin_City, 
    Destination_City, 
    Route_Type, 
    ROUND(AVG(Base_Lead_Time_Days)) as base_lead_time_days
FROM global_supply_chain_disruption_v1
GROUP BY Origin_City, Destination_City, Route_Type;

-- Populate products table
INSERT INTO products (product_category)
SELECT DISTINCT Product_Category
FROM global_supply_chain_disruption_v1
ORDER BY Product_Category;

-- Populate shipments table
INSERT INTO shipments (
    order_id, order_date, route_id, transportation_mode, 
    product_id, actual_lead_time_days, delivery_status, shipping_cost_usd
)
SELECT 
    s.Order_ID,
    s.Order_Date,
    r.route_id,
    s.Transportation_Mode,
    p.product_id,
    s.Actual_Lead_Time_Days,
    s.Delivery_Status,
    s.Shipping_Cost_USD
FROM global_supply_chain_disruption_v1 s
JOIN routes r ON s.Origin_City = r.origin_city 
    AND s.Destination_City = r.destination_city
JOIN products p ON s.Product_Category = p.product_category;

-- Populate shipments table
-- Convert date format from M/D/YYYY to MySQL DATE format
INSERT INTO shipments (
    order_id, order_date, route_id, transportation_mode, 
    product_id, actual_lead_time_days, delivery_status, shipping_cost_usd
)
SELECT 
    s.Order_ID,
    STR_TO_DATE(s.Order_Date, '%m/%d/%Y') as order_date,  -- Convert date format
    r.route_id,
    s.Transportation_Mode,
    p.product_id,
    s.Actual_Lead_Time_Days,
    s.Delivery_Status,
    s.Shipping_Cost_USD
FROM global_supply_chain_disruption_v1 s
JOIN routes r ON s.Origin_City = r.origin_city 
    AND s.Destination_City = r.destination_city
JOIN products p ON s.Product_Category = p.product_category;

-- Populate disruptions table
INSERT INTO disruptions (
    shipment_id, disruption_event, geopolitical_risk_index, 
    weather_severity_index, delay_days
)
SELECT 
    sh.shipment_id,
    s.Disruption_Event,
    s.Geopolitical_Risk_Index,
    s.Weather_Severity_Index,
    s.Delay_Days
FROM global_supply_chain_disruption_v1 s
JOIN shipments sh ON s.Order_ID = sh.order_id;

-- Populate mitigations table
INSERT INTO mitigations (shipment_id, mitigation_action_taken)
SELECT 
    sh.shipment_id,
    s.Mitigation_Action_Taken
FROM global_supply_chain_disruption_v1 s
JOIN shipments sh ON s.Order_ID = sh.order_id;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 5: DATA QUALITY CHECKS
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'Data Quality Report' as report_section;
SELECT '===================' as divider;

-- Check record counts
SELECT 'Routes' as table_name, COUNT(*) as record_count FROM routes
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'Disruptions', COUNT(*) FROM disruptions
UNION ALL
SELECT 'Mitigations', COUNT(*) FROM mitigations;

-- Check for missing values in critical fields
SELECT 'Missing Disruption Events' as check_type, 
       COUNT(*) as missing_count 
FROM disruptions 
WHERE disruption_event IS NULL;

-- Verify data integrity
SELECT 'Shipments without routes' as check_type, COUNT(*) as issue_count
FROM shipments s
LEFT JOIN routes r ON s.route_id = r.route_id
WHERE r.route_id IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 6: EXPLORATORY DATA ANALYSIS (20 BUSINESS QUESTIONS)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────
-- CATEGORY A: DISRUPTION ANALYSIS
-- ─────────────────────────────────────────────────────────────────────────

-- QUERY 1: Which disruption events cause the longest delays?
-- Business Value: Identify highest-impact disruption types for contingency planning
SELECT 
    '1. Disruption Impact Ranking' as analysis;

SELECT 
    d.disruption_event,
    COUNT(*) as occurrence_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    ROUND(MAX(d.delay_days), 2) as max_delay_days,
    ROUND(MIN(d.delay_days), 2) as min_delay_days,
    ROUND(SUM(d.delay_days), 2) as total_delay_days,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM disruptions), 2) as pct_of_total_disruptions
FROM disruptions d
WHERE d.disruption_event IS NOT NULL
GROUP BY d.disruption_event
ORDER BY avg_delay_days DESC;

-- QUERY 2: Delivery performance by disruption type
-- Business Value: Quantify impact on on-time delivery rates
SELECT 
    '2. Delivery Status by Disruption Type' as analysis;

SELECT 
    d.disruption_event,
    s.delivery_status,
    COUNT(*) as shipment_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY d.disruption_event), 2) as pct_within_disruption,
    ROUND(AVG(sh.shipping_cost_usd), 2) as avg_shipping_cost
FROM disruptions d
JOIN shipments s ON d.shipment_id = s.shipment_id
JOIN shipments sh ON s.shipment_id = sh.shipment_id
WHERE d.disruption_event IS NOT NULL
GROUP BY d.disruption_event, s.delivery_status
ORDER BY d.disruption_event, shipment_count DESC;

-- QUERY 3: Monthly disruption trends (2022-2024)
-- Business Value: Identify seasonal patterns for capacity planning
SELECT 
    '3. Monthly Disruption Trends' as analysis;
    

SELECT 
    YEAR(s.order_date) as year,
    MONTH(s.order_date) as month,
    DATE_FORMAT(s.order_date, '%Y-%m') as yearmonth,
    d.disruption_event,
    COUNT(*) as disruption_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay
FROM shipments s
JOIN disruptions d ON s.shipment_id = d.shipment_id
WHERE d.disruption_event IS NOT NULL
GROUP BY year, month, yearmonth, d.disruption_event
ORDER BY year, month, disruption_count DESC;

-- QUERY 4: Routes most vulnerable to disruptions
-- Business Value: Identify high-risk trade corridors
SELECT 
    '4. Most Disrupted Routes' as analysis;

SELECT 
    r.origin_city,
    r.destination_city,
    r.route_type,
    COUNT(DISTINCT d.shipment_id) as disrupted_shipments,
    COUNT(DISTINCT s.shipment_id) as total_shipments,
    ROUND(COUNT(DISTINCT d.shipment_id) * 100.0 / COUNT(DISTINCT s.shipment_id), 2) as disruption_rate_pct,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
LEFT JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.origin_city, r.destination_city, r.route_type
HAVING COUNT(DISTINCT s.shipment_id) > 50
ORDER BY disruption_rate_pct DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────────────────
-- CATEGORY B: RISK ASSESSMENT
-- ─────────────────────────────────────────────────────────────────────────

-- QUERY 5: Correlation between geopolitical risk and delays
-- Business Value: Quantify impact of political instability
SELECT 
    '5. Geopolitical Risk Impact Analysis' as analysis;

SELECT 
    CASE 
        WHEN d.geopolitical_risk_index < 0.3 THEN 'Low Risk (0-0.3)'
        WHEN d.geopolitical_risk_index < 0.6 THEN 'Medium Risk (0.3-0.6)'
        ELSE 'High Risk (0.6-1.0)'
    END as risk_category,
    COUNT(*) as shipment_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    ROUND(AVG(d.geopolitical_risk_index), 3) as avg_risk_index,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_shipping_cost,
    SUM(CASE WHEN s.delivery_status = 'Late' THEN 1 ELSE 0 END) as late_deliveries,
    ROUND(SUM(CASE WHEN s.delivery_status = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as late_pct
FROM disruptions d
JOIN shipments s ON d.shipment_id = s.shipment_id
GROUP BY risk_category
ORDER BY avg_risk_index;

-- QUERY 6: Weather severity impact on delivery
-- Business Value: Assess weather-related operational risks
SELECT 
    '6. Weather Severity Impact' as analysis;

SELECT 
    CASE 
        WHEN d.weather_severity_index < 3 THEN 'Mild (0-3)'
        WHEN d.weather_severity_index < 6 THEN 'Moderate (3-6)'
        ELSE 'Severe (6-10)'
    END as weather_category,
    COUNT(*) as shipment_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    ROUND(AVG(d.weather_severity_index), 2) as avg_severity_index,
    ROUND(MAX(d.delay_days), 2) as max_delay_days,
    SUM(CASE WHEN s.delivery_status = 'Late' THEN 1 ELSE 0 END) as late_count
FROM disruptions d
JOIN shipments s ON d.shipment_id = s.shipment_id
GROUP BY weather_category
ORDER BY avg_severity_index;

-- QUERY 7: Combined risk score analysis
-- Business Value: Holistic risk assessment combining multiple factors
SELECT 
    '7. Combined Risk Score Analysis' as analysis;

SELECT 
    r.route_type,
    ROUND(AVG(d.geopolitical_risk_index), 3) as avg_geo_risk,
    ROUND(AVG(d.weather_severity_index), 2) as avg_weather_risk,
    ROUND(AVG(d.geopolitical_risk_index) * 10 + AVG(d.weather_severity_index), 2) as combined_risk_score,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    COUNT(*) as shipment_count,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.route_type
ORDER BY combined_risk_score DESC;

-- QUERY 8: High-risk vs Low-risk route comparison
-- Business Value: Quantify premium for high-risk routes
SELECT 
    '8. Risk-Based Route Comparison' as analysis;

WITH risk_classification AS (
    SELECT 
        s.shipment_id,
        r.route_type,
        CASE 
            WHEN (d.geopolitical_risk_index + d.weather_severity_index/10) < 0.5 THEN 'Low Risk'
            WHEN (d.geopolitical_risk_index + d.weather_severity_index/10) < 0.8 THEN 'Medium Risk'
            ELSE 'High Risk'
        END as risk_level,
        d.delay_days,
        s.shipping_cost_usd,
        s.delivery_status
    FROM shipments s
    JOIN routes r ON s.route_id = r.route_id
    JOIN disruptions d ON s.shipment_id = d.shipment_id
)
SELECT 
    risk_level,
    COUNT(*) as shipment_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(shipping_cost_usd), 2) as avg_cost,
    ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as late_pct,
    ROUND(MAX(shipping_cost_usd) - MIN(shipping_cost_usd), 2) as cost_range
FROM risk_classification
GROUP BY risk_level
ORDER BY 
    CASE risk_level 
        WHEN 'Low Risk' THEN 1 
        WHEN 'Medium Risk' THEN 2 
        ELSE 3 
    END;

-- ─────────────────────────────────────────────────────────────────────────
-- CATEGORY C: ROUTE PERFORMANCE ANALYSIS
-- ─────────────────────────────────────────────────────────────────────────

-- QUERY 9: Average delay by route type
-- Business Value: Compare performance across major trade corridors
SELECT 
    '9. Route Type Performance Comparison' as analysis;

SELECT 
    r.route_type,
    COUNT(DISTINCT s.shipment_id) as total_shipments,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    ROUND(AVG(r.base_lead_time_days), 2) as avg_base_lead_time,
    ROUND(AVG(s.actual_lead_time_days), 2) as avg_actual_lead_time,
    ROUND(AVG(s.actual_lead_time_days - r.base_lead_time_days), 2) as avg_deviation,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_shipping_cost,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as on_time_count,
    ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.route_type
ORDER BY avg_delay_days;

-- QUERY 10: Most reliable routes (using window functions)
-- Business Value: Identify best-performing routes for strategic partnerships
SELECT 
    '10. Top 10 Most Reliable Routes' as analysis;

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
    delay_variance,
    on_time_pct,
    avg_cost,
    RANK() OVER (ORDER BY on_time_pct DESC, avg_delay ASC) as reliability_rank
FROM route_performance
ORDER BY reliability_rank
LIMIT 10;

-- QUERY 11: Route efficiency score
-- Business Value: Comprehensive route ranking for optimization
SELECT 
    '11. Route Efficiency Scoring' as analysis;

SELECT 
    r.origin_city,
    r.destination_city,
    r.route_type,
    COUNT(*) as shipment_count,
    ROUND(AVG(s.actual_lead_time_days), 2) as avg_actual_time,
    ROUND(AVG(r.base_lead_time_days), 2) as avg_base_time,
    ROUND((AVG(r.base_lead_time_days) / AVG(s.actual_lead_time_days)) * 100, 2) as efficiency_pct,
    ROUND(AVG(d.delay_days), 2) as avg_delay,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
    CASE 
        WHEN (AVG(r.base_lead_time_days) / AVG(s.actual_lead_time_days)) * 100 > 90 THEN 'Excellent'
        WHEN (AVG(r.base_lead_time_days) / AVG(s.actual_lead_time_days)) * 100 > 75 THEN 'Good'
        WHEN (AVG(r.base_lead_time_days) / AVG(s.actual_lead_time_days)) * 100 > 60 THEN 'Fair'
        ELSE 'Poor'
    END as performance_rating
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.origin_city, r.destination_city, r.route_type
HAVING shipment_count > 20
ORDER BY efficiency_pct DESC;

-- QUERY 12: Seasonal route patterns
-- Business Value: Identify seasonal bottlenecks for capacity planning
SELECT 
    '12. Seasonal Performance by Route' as analysis;

SELECT 
    r.route_type,
    QUARTER(s.order_date) as quarter,
    CASE QUARTER(s.order_date)
        WHEN 1 THEN 'Q1 (Jan-Mar)'
        WHEN 2 THEN 'Q2 (Apr-Jun)'
        WHEN 3 THEN 'Q3 (Jul-Sep)'
        WHEN 4 THEN 'Q4 (Oct-Dec)'
    END as quarter_name,
    COUNT(*) as shipment_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay,
    ROUND(AVG(d.weather_severity_index), 2) as avg_weather_severity,
    SUM(CASE WHEN s.delivery_status = 'Late' THEN 1 ELSE 0 END) as late_deliveries,
    ROUND(SUM(CASE WHEN s.delivery_status = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as late_pct
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.route_type, quarter, quarter_name
ORDER BY r.route_type, quarter;

-- ─────────────────────────────────────────────────────────────────────────
-- CATEGORY D: COST OPTIMIZATION ANALYSIS
-- ─────────────────────────────────────────────────────────────────────────

-- QUERY 13: Cost per delay day by transportation mode
-- Business Value: Quantify financial impact of delays by mode
SELECT 
    '13. Cost Impact by Transportation Mode' as analysis;

SELECT 
    s.transportation_mode,
    COUNT(*) as shipment_count,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_base_cost,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    ROUND(AVG(s.shipping_cost_usd) / NULLIF(AVG(d.delay_days), 0), 2) as cost_per_delay_day,
    ROUND(SUM(s.shipping_cost_usd), 2) as total_shipping_cost,
    ROUND(SUM(d.delay_days * 100), 2) as estimated_delay_cost_penalty,
    ROUND(AVG(s.actual_lead_time_days), 2) as avg_lead_time
FROM shipments s
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY s.transportation_mode
ORDER BY cost_per_delay_day DESC;

-- QUERY 14: ROI of mitigation actions
-- Business Value: Evaluate effectiveness of different mitigation strategies
SELECT 
    '14. Mitigation Strategy ROI Analysis' as analysis;

WITH mitigation_stats AS (
    SELECT 
        m.mitigation_action_taken,
        AVG(CASE WHEN m.mitigation_action_taken IS NOT NULL THEN d.delay_days END) as avg_delay_with_mitigation,
        AVG(CASE WHEN m.mitigation_action_taken IS NULL THEN d.delay_days END) as avg_delay_without_mitigation,
        AVG(CASE WHEN m.mitigation_action_taken IS NOT NULL THEN s.shipping_cost_usd END) as avg_cost_with_mitigation,
        AVG(CASE WHEN m.mitigation_action_taken IS NULL THEN s.shipping_cost_usd END) as avg_cost_without_mitigation,
        COUNT(CASE WHEN m.mitigation_action_taken IS NOT NULL THEN 1 END) as mitigation_count,
        COUNT(*) as total_shipments
    FROM mitigations m
    JOIN shipments s ON m.shipment_id = s.shipment_id
    JOIN disruptions d ON s.shipment_id = d.shipment_id
    GROUP BY m.mitigation_action_taken
)
SELECT 
    COALESCE(mitigation_action_taken, 'No Mitigation') as mitigation_strategy,
    mitigation_count,
    total_shipments,
    ROUND(mitigation_count * 100.0 / total_shipments, 2) as mitigation_usage_pct,
    ROUND(avg_delay_with_mitigation, 2) as avg_delay_with,
    ROUND(avg_delay_without_mitigation, 2) as avg_delay_without,
    ROUND(avg_delay_without_mitigation - avg_delay_with_mitigation, 2) as delay_reduction_days,
    ROUND(avg_cost_with_mitigation, 2) as avg_cost_with,
    ROUND(avg_cost_without_mitigation, 2) as avg_cost_without,
    ROUND(avg_cost_with_mitigation - avg_cost_without_mitigation, 2) as cost_premium
FROM mitigation_stats
WHERE mitigation_action_taken IS NOT NULL
ORDER BY delay_reduction_days DESC;

-- QUERY 15: Sea vs Air cost-benefit analysis
-- Business Value: Optimize mode selection for different scenarios
SELECT 
    '15. Transportation Mode Cost-Benefit Analysis' as analysis;

WITH mode_comparison AS (
    SELECT 
        s.transportation_mode,
        p.product_category,
        COUNT(*) as shipment_count,
        ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
        ROUND(AVG(d.delay_days), 2) as avg_delay,
        ROUND(AVG(s.actual_lead_time_days), 2) as avg_lead_time,
        SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as on_time_count,
        ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct
    FROM shipments s
    JOIN disruptions d ON s.shipment_id = d.shipment_id
    JOIN products p ON s.product_id = p.product_id
    WHERE s.transportation_mode IN ('Sea', 'Air')
    GROUP BY s.transportation_mode, p.product_category
)
SELECT 
    product_category,
    transportation_mode,
    shipment_count,
    avg_cost,
    avg_delay,
    avg_lead_time,
    on_time_pct,
    ROUND(avg_cost / avg_lead_time, 2) as cost_per_day,
    CASE 
        WHEN transportation_mode = 'Air' AND on_time_pct > 85 THEN 'Recommended for urgent'
        WHEN transportation_mode = 'Sea' AND avg_cost < 2000 THEN 'Recommended for cost-sensitive'
        ELSE 'Conditional use'
    END as recommendation
FROM mode_comparison
ORDER BY product_category, avg_cost;

-- QUERY 16: Premium cost due to risk indices
-- Business Value: Quantify risk-based pricing
SELECT 
    '16. Risk-Based Cost Premium Analysis' as analysis;

SELECT 
    CASE 
        WHEN (d.geopolitical_risk_index + d.weather_severity_index/10) < 0.5 THEN 'Low Risk'
        WHEN (d.geopolitical_risk_index + d.weather_severity_index/10) < 0.8 THEN 'Medium Risk'
        ELSE 'High Risk'
    END as combined_risk_level,
    s.transportation_mode,
    COUNT(*) as shipment_count,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_shipping_cost,
    ROUND(MIN(s.shipping_cost_usd), 2) as min_cost,
    ROUND(MAX(s.shipping_cost_usd), 2) as max_cost,
    ROUND(AVG(d.geopolitical_risk_index), 3) as avg_geo_risk,
    ROUND(AVG(d.weather_severity_index), 2) as avg_weather_risk
FROM shipments s
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY combined_risk_level, s.transportation_mode
ORDER BY combined_risk_level, avg_shipping_cost DESC;

-- ─────────────────────────────────────────────────────────────────────────
-- CATEGORY E: MITIGATION EFFECTIVENESS
-- ─────────────────────────────────────────────────────────────────────────

-- QUERY 17: Success rate of each mitigation action
-- Business Value: Identify most effective mitigation strategies
SELECT 
    '17. Mitigation Action Success Rate' as analysis;

SELECT 
    m.mitigation_action_taken,
    COUNT(*) as total_actions,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as successful_deliveries,
    ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate_pct,
    ROUND(AVG(d.delay_days), 2) as avg_delay_after_mitigation,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
    ROUND(AVG(s.actual_lead_time_days), 2) as avg_actual_lead_time
FROM mitigations m
JOIN shipments s ON m.shipment_id = s.shipment_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
WHERE m.mitigation_action_taken IS NOT NULL
GROUP BY m.mitigation_action_taken
ORDER BY success_rate_pct DESC;

-- QUERY 18: Cost-effectiveness of re-routing vs expediting
-- Business Value: Determine optimal response strategy
SELECT 
    '18. Re-routing vs Expediting Comparison' as analysis;

SELECT 
    CASE 
        WHEN m.mitigation_action_taken LIKE '%Re-routing%' THEN 'Re-routing'
        WHEN m.mitigation_action_taken LIKE '%Expedited%' OR m.mitigation_action_taken LIKE '%Air%' THEN 'Expediting'
        ELSE 'Other'
    END as mitigation_type,
    COUNT(*) as usage_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
    ROUND(AVG(s.actual_lead_time_days - r.base_lead_time_days), 2) as avg_time_deviation,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as on_time_count,
    ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(AVG(s.shipping_cost_usd) / NULLIF(AVG(d.delay_days), 0), 2) as cost_efficiency_ratio
FROM mitigations m
JOIN shipments s ON m.shipment_id = s.shipment_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
JOIN routes r ON s.route_id = r.route_id
WHERE m.mitigation_action_taken IS NOT NULL
GROUP BY mitigation_type
HAVING mitigation_type IN ('Re-routing', 'Expediting')
ORDER BY cost_efficiency_ratio DESC;

-- QUERY 19: Product category mitigation preferences
-- Business Value: Tailor mitigation strategies by product type
SELECT 
    '19. Mitigation Strategy by Product Category' as analysis;

SELECT 
    p.product_category,
    m.mitigation_action_taken,
    COUNT(*) as usage_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay_reduction,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as successful_deliveries,
    ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate,
    RANK() OVER (PARTITION BY p.product_category ORDER BY 
        SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC) as effectiveness_rank
FROM products p
JOIN shipments s ON p.product_id = s.product_id
JOIN mitigations m ON s.shipment_id = m.shipment_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
WHERE m.mitigation_action_taken IS NOT NULL
GROUP BY p.product_category, m.mitigation_action_taken
HAVING usage_count > 5
ORDER BY p.product_category, effectiveness_rank;

-- QUERY 20: Optimal mitigation by disruption type (ADVANCED ANALYSIS)
-- Business Value: Create decision matrix for operational playbook
SELECT 
    '20. Optimal Mitigation Strategy Matrix' as analysis;

WITH disruption_mitigation_performance AS (
    SELECT 
        d.disruption_event,
        m.mitigation_action_taken,
        COUNT(*) as instances,
        ROUND(AVG(d.delay_days), 2) as avg_delay,
        ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
        SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as on_time_deliveries,
        ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate,
        ROUND(AVG(s.shipping_cost_usd) / NULLIF(AVG(d.delay_days), 0), 2) as cost_per_delay_day
    FROM disruptions d
    JOIN mitigations m ON d.shipment_id = m.shipment_id
    JOIN shipments s ON d.shipment_id = s.shipment_id
    WHERE d.disruption_event IS NOT NULL 
      AND m.mitigation_action_taken IS NOT NULL
    GROUP BY d.disruption_event, m.mitigation_action_taken
    HAVING instances > 3
),
ranked_strategies AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY disruption_event 
                          ORDER BY success_rate DESC, avg_delay ASC, avg_cost ASC) as strategy_rank
    FROM disruption_mitigation_performance
)
SELECT 
    disruption_event,
    mitigation_action_taken as recommended_strategy,
    instances,
    avg_delay as avg_delay_days,
    avg_cost as avg_cost_usd,
    success_rate as success_rate_pct,
    cost_per_delay_day,
    CASE 
        WHEN success_rate > 80 AND avg_delay < 5 THEN 'Highly Effective'
        WHEN success_rate > 60 THEN 'Effective'
        WHEN success_rate > 40 THEN 'Moderately Effective'
        ELSE 'Limited Effectiveness'
    END as effectiveness_rating
FROM ranked_strategies
WHERE strategy_rank = 1
ORDER BY disruption_event;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 7: ADVANCED ANALYTICS - BONUS QUERIES
-- ═══════════════════════════════════════════════════════════════════════════

-- BONUS QUERY 1: Running total of delays by month (Window Function Showcase)
SELECT 
    'BONUS 1: Monthly Delay Trends with Running Total' as analysis;

WITH monthly_delays AS (
    SELECT 
        DATE_FORMAT(s.order_date, '%Y-%m') as yearmonth,
        SUM(d.delay_days) as total_delay_days,
        COUNT(*) as shipment_count,
        ROUND(AVG(d.delay_days), 2) as avg_delay
    FROM shipments s
    JOIN disruptions d ON s.shipment_id = d.shipment_id
    GROUP BY yearmonth
)
SELECT 
    yearmonth,
    shipment_count,
    total_delay_days,
    avg_delay,
    SUM(total_delay_days) OVER (ORDER BY yearmonth) as running_total_delays,
    ROUND(AVG(avg_delay) OVER (ORDER BY yearmonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as three_month_moving_avg
FROM monthly_delays
ORDER BY yearmonth;

-- BONUS QUERY 2: Customer-centric route reliability score
SELECT 
    'BONUS 2: Route Reliability Scorecard' as analysis;

SELECT 
    r.origin_city,
    r.destination_city,
    r.route_type,
    COUNT(*) as total_shipments,
    ROUND(AVG(CASE WHEN s.delivery_status = 'On Time' THEN 100 ELSE 0 END), 2) as on_time_score,
    ROUND(100 - (AVG(d.delay_days) / r.base_lead_time_days * 100), 2) as schedule_adherence_score,
    ROUND((1 - AVG(d.geopolitical_risk_index)) * 100, 2) as stability_score,
    ROUND((10 - AVG(d.weather_severity_index)) * 10, 2) as weather_reliability_score,
    ROUND((
        (AVG(CASE WHEN s.delivery_status = 'On Time' THEN 100 ELSE 0 END) * 0.4) +
        ((100 - (AVG(d.delay_days) / r.base_lead_time_days * 100)) * 0.3) +
        ((1 - AVG(d.geopolitical_risk_index)) * 100 * 0.15) +
        ((10 - AVG(d.weather_severity_index)) * 10 * 0.15)
    ), 2) as composite_reliability_score
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.origin_city, r.destination_city, r.route_type, r.base_lead_time_days
HAVING total_shipments > 20
ORDER BY composite_reliability_score DESC
LIMIT 15;

-- BONUS QUERY 3: Predictive delay probability scoring
SELECT 
    'BONUS 3: Delay Risk Probability by Scenario' as analysis;

SELECT 
    r.route_type,
    s.transportation_mode,
    d.disruption_event,
    COUNT(*) as scenario_count,
    SUM(CASE WHEN d.delay_days > 5 THEN 1 ELSE 0 END) as major_delay_count,
    ROUND(SUM(CASE WHEN d.delay_days > 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as major_delay_probability,
    ROUND(AVG(d.geopolitical_risk_index), 3) as avg_geo_risk,
    ROUND(AVG(d.weather_severity_index), 2) as avg_weather_risk,
    ROUND(AVG(d.delay_days), 2) as expected_delay_days,
    CASE 
        WHEN SUM(CASE WHEN d.delay_days > 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 50 THEN 'High Risk'
        WHEN SUM(CASE WHEN d.delay_days > 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 25 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
WHERE d.disruption_event IS NOT NULL
GROUP BY r.route_type, s.transportation_mode, d.disruption_event
HAVING scenario_count > 10
ORDER BY major_delay_probability DESC
LIMIT 20;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 8: EXECUTIVE SUMMARY DASHBOARD QUERIES
-- ═══════════════════════════════════════════════════════════════════════════

-- KPI 1: Overall Performance Metrics
SELECT 'EXECUTIVE SUMMARY - Key Performance Indicators' as report_title;

SELECT 
    'Overall Performance' as metric_category,
    COUNT(*) as total_shipments,
    SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) as on_time_deliveries,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(AVG(actual_lead_time_days), 2) as avg_lead_time_days,
    ROUND(SUM(shipping_cost_usd), 2) as total_shipping_cost,
    ROUND(AVG(shipping_cost_usd), 2) as avg_cost_per_shipment
FROM shipments;

-- KPI 2: Disruption Summary
SELECT 
    'Disruption Impact' as metric_category,
    COUNT(DISTINCT CASE WHEN disruption_event IS NOT NULL THEN shipment_id END) as disrupted_shipments,
    ROUND(COUNT(DISTINCT CASE WHEN disruption_event IS NOT NULL THEN shipment_id END) * 100.0 / 
          COUNT(DISTINCT shipment_id), 2) as disruption_rate_pct,
    ROUND(AVG(delay_days), 2) as avg_delay_days,
    SUM(delay_days) as total_delay_days,
    ROUND(SUM(delay_days) * 100, 2) as estimated_delay_cost_usd
FROM disruptions;

-- KPI 3: Top Risk Areas
SELECT 
    'Top 5 Highest Risk Routes' as metric_category,
    r.origin_city,
    r.destination_city,
    COUNT(*) as shipments,
    ROUND(AVG(d.delay_days), 2) as avg_delay,
    ROUND(AVG(d.geopolitical_risk_index + d.weather_severity_index/10), 3) as combined_risk_score
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.origin_city, r.destination_city
ORDER BY combined_risk_score DESC
LIMIT 5;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 9: DATA EXPORT FOR VISUALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

-- Export 1: Monthly trends for Tableau/Power BI
CREATE OR REPLACE VIEW v_monthly_trends AS
SELECT 
    DATE_FORMAT(s.order_date, '%Y-%m') as yearmonth,
    YEAR(s.order_date) as year,
    MONTH(s.order_date) as month,
    COUNT(*) as shipment_count,
    SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) as on_time_count,
    ROUND(AVG(d.delay_days), 2) as avg_delay_days,
    ROUND(SUM(s.shipping_cost_usd), 2) as total_cost,
    COUNT(DISTINCT d.disruption_event) as unique_disruptions
FROM shipments s
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY yearmonth, year, month
ORDER BY yearmonth;

-- Export 2: Route performance summary
CREATE OR REPLACE VIEW v_route_performance AS
SELECT 
    r.route_id,
    r.origin_city,
    r.destination_city,
    r.route_type,
    COUNT(*) as total_shipments,
    ROUND(AVG(d.delay_days), 2) as avg_delay,
    ROUND(AVG(s.shipping_cost_usd), 2) as avg_cost,
    ROUND(AVG(d.geopolitical_risk_index), 3) as avg_geo_risk,
    ROUND(AVG(d.weather_severity_index), 2) as avg_weather_risk,
    ROUND(SUM(CASE WHEN s.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN disruptions d ON s.shipment_id = d.shipment_id
GROUP BY r.route_id, r.origin_city, r.destination_city, r.route_type;

-- ═══════════════════════════════════════════════════════════════════════════
-- PROJECT COMPLETE
-- ═══════════════════════════════════════════════════════════════════════════

SELECT 'Analysis Complete!' as status,
       'Total Queries Executed: 20 Business Questions + 3 Bonus + KPI Dashboard' as summary,
       'Views Created: 2 for visualization tools' as deliverables;

