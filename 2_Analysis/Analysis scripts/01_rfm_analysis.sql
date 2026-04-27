/*
===========================================================
📊 Analysis: RFM Customer Segmentation

🧠 Objective:
Segment customers based on Recency, Frequency, and Monetary value
to identify high-value users, churn risks, and growth opportunities.

⚙️ Methodology:
- Recency (R): Scored using CUME_DIST (better than NTILE for distribution accuracy)
- Frequency (F): Bucketed using business-defined order ranges
- Monetary (M): Scored using revenue distribution

📈 Output:
- R, F, M scores (1–5 scale)
- Combined RFM code
- Customer segments (Champions, Loyal, At Risk, etc.)

💡 Key Notes:
- Recency is treated as the strongest behavioral indicator
- Segment ordering is carefully designed to avoid misclassification
===========================================================
*/

/*
-----------------------------------------------------------
🧠 Design Decisions & Justification

1. Why CUME_DIST() instead of NTILE(5)?
   - NTILE creates equal-sized buckets but can split identical values across groups
   - This leads to inconsistent scoring when many customers share the same recency
   - CUME_DIST ensures a true cumulative distribution:
       → All equal values receive the same score
       → More stable and realistic segmentation

2. Why not PERCENT_RANK()?
   - PERCENT_RANK starts at 0 and ends at 1 but:
       → It is sensitive to dataset size
       → Produces uneven distribution for small datasets
   - CUME_DIST provides smoother and more intuitive grouping for scoring

3. Why custom bucketing for Frequency (F-score)?
   - Order counts are discrete and often skewed
   - Using NTILE here would:
       → Over-fragment meaningful behavioral groups
   - Business-defined buckets are more interpretable:
       → 1 order = new
       → 2–3 = early repeat
       → 6+ = loyal/high frequency

4. Why Recency is prioritized in segmentation?
   - Recency is the strongest signal of churn risk
   - A customer inactive recently is more actionable than one with past high value

-----------------------------------------------------------
*/


WITH rfm AS (
    SELECT 
        customer,
        fullname,
        recency,
        no_of_orders,
        total_sales,

        -- R Score: lower recency = better → invert distribution
        CEILING(5 * (1 - CUME_DIST() OVER (ORDER BY recency))) AS r_score,

        -- F Score: business-defined buckets
        CASE 
            WHEN no_of_orders = 1 THEN 1
            WHEN no_of_orders BETWEEN 2 AND 3 THEN 2
            WHEN no_of_orders BETWEEN 4 AND 5 THEN 3
            WHEN no_of_orders BETWEEN 6 AND 10 THEN 4
            ELSE 5
        END AS f_score,

        -- M Score: higher revenue = better
        CEILING(5 * CUME_DIST() OVER (ORDER BY total_sales)) AS m_score

    FROM gold.report_customers
),

rfm_segmented AS (
    SELECT *,
        
        -- Combine scores into RFM code
        CONCAT(r_score, f_score, m_score) AS rfm_code,

        -- Customer segmentation logic
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'

            WHEN r_score >= 4 AND f_score >= 4 AND m_score BETWEEN 2 AND 3 THEN 'Loyal Customers'

            -- Important: placed before broader rules to avoid misclassification
            WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 4 THEN 'High Value Potential'

            WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'

            WHEN r_score >= 3 AND f_score BETWEEN 2 AND 3 THEN 'Potential Loyalists'

            -- Recency = 1 is dominant → must come early
            WHEN r_score = 1 THEN 'Lost'

            WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'

            WHEN r_score <= 2 AND m_score >= 4 THEN 'Cannot Lose Them'

            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Hibernating'

            ELSE 'Others'
        END AS customer_segment

    FROM rfm
)

-- Final Output
SELECT 
    customer,
    fullname,
    recency,
    no_of_orders,
    total_sales,
    r_score,
    f_score,
    m_score,
    rfm_code,
    customer_segment
FROM rfm_segmented

 /*NOTE:
 Segment order is critical:
 More specific segments must be evaluated before broader ones
 to prevent incorrect classification
 */

-----------------------------------------------------------
/*Analysis Queries*/
-----------------------------------------------------------

-- Distribution of customers across segments
--SELECT 
--    customer_segment,
--    COUNT(*) AS customer_count
--FROM rfm_segmented
--GROUP BY customer_segment
--ORDER BY customer_count DESC;

-- Revenue contribution by segment
--SELECT 
--    customer_segment,
--    COUNT(*) AS customers,
--    SUM(total_sales) AS total_revenue,
--    SUM(total_sales) * 1.0 / SUM(SUM(total_sales)) OVER () AS revenue_pct
--FROM rfm_segmented
--GROUP BY customer_segment
--ORDER BY total_revenue DESC;