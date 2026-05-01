/*
===========================================================
Analysis: Product Revenue Volatility

Objective:
Measure how stable or volatile product revenue is over time
to identify:

- Consistently performing products
- Unstable, unpredictable products

-----------------------------------------------------------

Methodology:
1. Aggregate revenue at monthly level per product
2. Calculate:
    → Average monthly revenue
    → Standard deviation (volatility)
    → Coefficient of variation (CV = volatility / average)
3. Classify products based on volatility levels

-----------------------------------------------------------

Output:
- Avg monthly revenue
- Revenue volatility (standard deviation)
- CV (relative volatility)
- Stability classification

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

1. Why aggregate by month (EOMONTH)?
   - Standardizes time intervals
   - Enables consistent comparison across products

2. Why use STDEV()?
   - Measures variability in revenue over time
   - Higher value → more fluctuation

3. Why use Coefficient of Variation (CV)?
   - Normalizes volatility relative to average revenue
   - Allows comparison across products of different scales

4. Why not use only STDEV?
   - High-revenue products naturally have higher variance
   - CV provides a fair comparison

-----------------------------------------------------------
*/

-- NOTE:
-- Volatility may be influenced by:
--   → Seasonality
--   → Promotions
--   → Product lifecycle
-- Further analysis can include time-series decomposition

WITH monthly_revenue AS (
    SELECT
        p.product_key,
        p.product_name,
        EOMONTH(f.order_date) AS month,
        SUM(f.sales_amount) AS monthly_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        p.product_key,
        p.product_name,
        EOMONTH(f.order_date)
),

stats AS (
    SELECT
        product_name,
        AVG(monthly_revenue) AS avg_monthly_revenue,
        STDEV(monthly_revenue) AS revenue_volatility,
        STDEV(monthly_revenue) * 1.0 / NULLIF(AVG(monthly_revenue), 0) AS cv
    FROM monthly_revenue
    GROUP BY product_name
)

SELECT
    product_name,
    avg_monthly_revenue,
    revenue_volatility,
    cv,

    -- Stability flag (absolute comparison)
    CASE 
        WHEN revenue_volatility > avg_monthly_revenue * 0.5 THEN 'Unstable'
        ELSE 'Stable'
    END AS stability_flag,

    -- Relative volatility classification (CV-based)
    CASE 
        WHEN cv > 0.5 THEN 'High volatility'
        WHEN cv > 0.2 THEN 'Medium'
        ELSE 'Low'
    END AS volatility_level

FROM stats
ORDER BY revenue_volatility DESC;