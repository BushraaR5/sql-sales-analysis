# 📊 E-commerce Customer & Revenue Analysis (SQL Case Study)

## 🧠 Project Overview

This project analyzes an e-commerce dataset using advanced SQL techniques to uncover insights related to customer behavior, revenue distribution, product performance, and business risk.

The goal is to simulate a real-world business scenario where SQL is used not just for querying data, but for generating actionable insights that can support decision-making.

---

## 🎯 Objectives

- Identify high-value and loyal customers
- Analyze revenue concentration and customer contribution
- Understand customer retention and lifecycle patterns
- Evaluate product performance and sales trends
- Detect churn risks and inventory inefficiencies
- Explore product relationships for cross-selling opportunities

---

## 📂 Data Source & Acknowledgment

This project uses datasets and base structure from:

**DataWithBaraa – SQL Data Analytics Project**

The original project demonstrates foundational SQL analytics.

This version extends the analysis with additional queries, deeper business logic, and advanced analytical techniques.

All analysis, query design, and insights in this project were developed independently.

---

## 📊 Key Analyses Performed

### 1. Customer Segmentation (RFM Analysis)

- Used `CUME_DIST()` instead of NTILE for more accurate distribution-based scoring
- Segmented customers into groups like Champions, Loyal, At Risk, etc.
- Focused on interpreting recency as a dominant behavioral signal

---

### 2. Revenue Concentration (Pareto Analysis)

- Identified contribution of top 20% customers
- Found that a small percentage of customers drive a large share of revenue
- Highlighted existence of a high-value core customer base

---

### 3. Customer Cohort Analysis

- Grouped customers by acquisition year
- Compared revenue quality and lifespan across cohorts
- Observed retention patterns over time

---

### 4. Monthly Sales Trend

- Analyzed month-over-month growth using window functions
- Used `LAG()` to calculate growth rates
- Identified seasonality and trend shifts

---

### 5. Product Ranking Within Categories

- Ranked products using `ROW_NUMBER()` and `CROSS APPLY`
- Identified top-performing products per category and subcategory

---

### 6. Customer Spending Trend

- Calculated running totals and rolling sales per customer
- Tracked how customer spending evolves over time

---

### 7. Product Contribution Analysis

- Measured revenue contribution within categories
- Calculated cumulative percentage to identify key products driving revenue

---

### 8. Churn Analysis

- Identified churned customers using recency thresholds
- Calculated percentage of customers lost and associated revenue impact
- Optimized query using conditional aggregation

---

### 9. Customer Lifetime Value (LTV)

- Calculated LTV using total revenue and customer lifespan
- Ranked customers based on long-term value

---

### 10. Basket Analysis (Lite)

- Identified frequently purchased product pairs
- Calculated Support, Confidence, and Lift
- Highlighted cross-selling opportunities

---

### 11. Product Revenue Volatility

- Measured stability using standard deviation and coefficient of variation
- Classified products into stable vs volatile categories

---

### 12. Aging Inventory Risk

- Used percentile thresholds to classify inventory risk levels
- Identified slow-moving products with high recency

---

### 13. Customer Retention Curve

- Measured customer activity consistency over time
- Compared active months vs total lifespan
- Derived retention ratio per customer

---

## 🔍 Key Insights

- A small percentage of customers contributes disproportionately to revenue
- High-value customers can be identified early using RFM segmentation
- Certain products dominate category revenue, indicating dependency risk
- Product bundles show strong association, enabling recommendation systems
- Customer churn impacts both volume and revenue significantly
- Revenue volatility highlights demand instability in certain products

---

## 🛠️ SQL Techniques Used

- Window Functions (`CUME_DIST`, `LAG`, `RANK`, `ROW_NUMBER`)
- Common Table Expressions (CTEs)
- Conditional Aggregation
- CROSS APPLY
- Percentile Functions (`PERCENTILE_CONT`)
- Analytical Metrics (RFM, LTV, Retention, Pareto)

---

## 🚀 Future Improvements

- Build an interactive Power BI dashboard
- Automate analysis using stored procedures
- Extend basket analysis into recommendation system logic
- Add time-series forecasting for revenue trends
