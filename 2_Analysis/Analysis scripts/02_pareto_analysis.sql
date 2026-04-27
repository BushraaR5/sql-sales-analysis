/*
===========================================================
📊 Analysis: Revenue Concentration (Pareto Analysis)

🧠 Objective:
Analyze how revenue is distributed across customers and
determine whether a small percentage of customers contributes
a large portion of total revenue.

Specifically:
- What % of revenue comes from top 20% customers?
- What % of customers generate 20% of revenue?

-----------------------------------------------------------

⚙️ Methodology:
1. Rank customers based on total_sales (descending)
2. Compute cumulative revenue using window functions
3. Identify:
   - Top 20% customers → measure their revenue contribution
   - Customers contributing to first 20% of revenue

-----------------------------------------------------------

📈 Output:
- % Revenue from top 20% customers
- % Customers contributing to 20% revenue

===========================================================
*/

/*
-----------------------------------------------------------
🧠 Design Decisions & Justification

1. Why use RANK() instead of ROW_NUMBER()?
   - Customers may have identical total_sales
   - ROW_NUMBER() would break ties arbitrarily
   - RANK() ensures fair inclusion at threshold boundaries

2. Why ROWS instead of default RANGE?
   - Default = RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
   - RANGE groups identical values together → incorrect cumulative sums
   - ROWS ensures true row-by-row accumulation

3. Why cumulative revenue?
   - Required to identify contribution thresholds (20%, 50%, etc.)
   - Enables Pareto-style analysis

4. Why FLOOR(0.2 * COUNT(*))?
   - Ensures exact top 20% selection
   - Avoids fractional row ambiguity

-----------------------------------------------------------
*/

WITH top20_revenue AS (
    SELECT 
        customer,
        fullname,
        total_sales,

        -- Running cumulative revenue (correct row-wise accumulation)
        SUM(total_sales) OVER (
            ORDER BY total_sales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,

        -- Rank customers by revenue
        RANK() OVER (ORDER BY total_sales DESC) AS rnk

    FROM gold.report_customers
)

-----------------------------------------------------------
-- 📊 1. % Revenue from Top 20% Customers
-----------------------------------------------------------
SELECT
    ROUND(
        (SUM(total_sales) * 1.0 /
        (SELECT SUM(total_sales) FROM gold.report_customers)) * 100,
        2
    ) AS revenue_pct_top_20
FROM top20_revenue
WHERE rnk <= FLOOR(0.2 * (SELECT COUNT(*) FROM gold.report_customers));

-----------------------------------------------------------
-- 📊 2. % Customers that generate 20% Revenue
-----------------------------------------------------------

-- Comment previous select query and uncomment the below to get result for the below

-- SELECT
--    ROUND(
--        (COUNT(*) * 1.0 /
--        (SELECT COUNT(*) FROM gold.report_customers)) * 100,
--        2
--    ) AS customer_pct_for_20_revenue
-- FROM top20_revenue
-- WHERE cumulative_revenue <= 
--      0.2 * (SELECT SUM(total_sales) FROM gold.report_customers);