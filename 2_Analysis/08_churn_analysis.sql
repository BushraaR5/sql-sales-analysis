/*
===========================================================
📊 Analysis: Customer Churn & Revenue Impact

🧠 Objective:
Identify churned customers and quantify their impact on:
- Customer base (% churned)
- Revenue (% revenue lost)

-----------------------------------------------------------

📌 Churn Definition:
- Customers with recency > 6 months are considered churned

-----------------------------------------------------------

⚙️ Methodology:
- Use conditional aggregation to:
    → Count churned customers
    → Sum their revenue
    → Calculate % impact on total customers and revenue

-----------------------------------------------------------

📈 Output:
- % of customers churned
- Revenue from churned customers
- % of revenue lost due to churn

===========================================================
*/

/*
-----------------------------------------------------------
🧠 Design Decisions & Justification

1. Why conditional aggregation?
   - Avoids multiple scans of the same table
   - Improves performance and efficiency
   - Computes all metrics in a single pass

2. Why not use separate queries?
   - Would require repeated full-table scans
   - Less efficient for large datasets

3. Why recency > 6 months?
   - Common business heuristic for inactivity
   - Indicates disengagement and potential churn

-----------------------------------------------------------
*/

-- Note:
-- Recency threshold (6 months) is a business assumption
-- In real scenarios, this should be validated using:
--   → historical churn behavior
--   → industry benchmarks

SELECT 
    -- % of customers churned
    SUM(CASE WHEN recency > 6 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) 
        AS pct_churned,

    -- Revenue from churned customers
    SUM(CASE WHEN recency > 6 THEN total_sales ELSE 0 END) 
        AS revenue_from_churned,

    -- % of total revenue lost
    SUM(CASE WHEN recency > 6 THEN total_sales ELSE 0 END) * 1.0 
        / SUM(total_sales) 
        AS pct_revenue_lost_from_churned

FROM gold.report_customers;

-- Churn breakdown by segment (if combined with RFM)

-- WITH rfm AS (
--    SELECT 
--        customer,
--        fullname,
--        recency,
--        no_of_orders,
--        total_sales,

--        -- R Score: lower recency = better → invert distribution
--        CEILING(5 * (1 - CUME_DIST() OVER (ORDER BY recency))) AS r_score,

--        -- F Score: business-defined buckets
--        CASE 
--            WHEN no_of_orders = 1 THEN 1
--            WHEN no_of_orders BETWEEN 2 AND 3 THEN 2
--            WHEN no_of_orders BETWEEN 4 AND 5 THEN 3
--            WHEN no_of_orders BETWEEN 6 AND 10 THEN 4
--            ELSE 5
--        END AS f_score,

--        -- M Score: higher revenue = better
--        CEILING(5 * CUME_DIST() OVER (ORDER BY total_sales)) AS m_score

--    FROM gold.report_customers
-- ),

-- rfm_segmented AS (
--    SELECT *,
        
--        -- Combine scores into RFM code
--        CONCAT(r_score, f_score, m_score) AS rfm_code,

--        -- Customer segmentation logic
--        CASE
--            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'

--            WHEN r_score >= 4 AND f_score >= 4 AND m_score BETWEEN 2 AND 3 THEN 'Loyal Customers'

--            -- Important: placed before broader rules to avoid misclassification
--            WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 4 THEN 'High Value Potential'

--            WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'

--            WHEN r_score >= 3 AND f_score BETWEEN 2 AND 3 THEN 'Potential Loyalists'

--            -- Recency = 1 is dominant → must come early
--            WHEN r_score = 1 THEN 'Lost'

--            WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'

--            WHEN r_score <= 2 AND m_score >= 4 THEN 'Cannot Lose Them'

--            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Hibernating'

--            ELSE 'Others'
--        END AS customer_segment

--    FROM rfm
-- )

-- -- Final Output
-- SELECT 
-- customer_segment,
--    COUNT(*) AS churned_customers,
--    SUM(total_sales) AS churned_revenue
-- --FROM gold.report_customers
-- FROM rfm_segmented
-- WHERE recency > 6
-- GROUP BY customer_segment
-- ORDER BY churned_revenue DESC;