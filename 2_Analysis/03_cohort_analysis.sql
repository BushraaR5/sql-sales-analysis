/*
===========================================================
Analysis: Customer Cohort Analysis

Objective:
Analyze customer behavior based on acquisition cohorts
(year of first purchase) to understand:

- Customer growth over time
- Revenue quality across cohorts
- Customer lifespan trends

-----------------------------------------------------------

Methodology:
- Define cohort as: YEAR(first_order)
- Aggregate metrics per cohort:
    → Total customers
    → Average total sales
    → Average lifespan

-----------------------------------------------------------

Output:
One row per cohort year with key performance metrics

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

1. Why use YEAR(first_order)?
   - Represents customer acquisition timing
   - Groups customers based on when they entered the system

2. Why use report_customers table?
   - Already contains aggregated metrics:
       → total_sales
       → lifespan
       → first_order
   - Avoids recomputation from fact table

3. Why average lifespan and sales?
   - Helps compare cohort quality, not just size
   - Identifies whether newer customers are improving or declining

-----------------------------------------------------------
*/

SELECT
    YEAR(first_order) AS cohort_year,

    COUNT(DISTINCT customer) AS total_customers,

    AVG(total_sales) AS avg_total_sales,

    AVG(lifespan) AS avg_lifespan

FROM gold.report_customers
GROUP BY YEAR(first_order)
ORDER BY cohort_year;

-- % contribution of each cohort to total revenue

SELECT
    YEAR(first_order) AS cohort_year,
    SUM(total_sales) AS cohort_revenue,
    SUM(total_sales) * 1.0 / SUM(SUM(total_sales)) OVER () AS revenue_pct
FROM gold.report_customers
GROUP BY YEAR(first_order)
ORDER BY cohort_year;