/*
===========================================================
Analysis: Aging Inventory Risk

Objective:
Identify products at risk of becoming dead stock by combining:

- Low sales performance
- High recency (not sold recently)

-----------------------------------------------------------

Risk Definition:
Products are considered at risk if:
- recency > 6 months (not sold recently)
- AND total_sales below defined thresholds

-----------------------------------------------------------

Methodology:
1. Calculate sales thresholds using percentiles:
    → P25 (low-performing products)
    → P50 (median performance)

2. Classify products into:
    → High Risk (low sales + inactive)
    → Medium Risk
    → Healthy

-----------------------------------------------------------

Output:
- Product details
- Sales thresholds (P25, P50)
- Inventory risk classification

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

1. Why use PERCENTILE_CONT()?
   - Dynamically calculates thresholds based on data distribution
   - More robust than fixed cutoffs

2. Why use TOP 1 instead of DISTINCT?
   - Avoids unnecessary deduplication step
   - Improves performance

3. Why combine recency + sales?
   - Low sales alone ≠ risk
   - High recency confirms lack of demand

4. Why use CROSS JOIN?
   - Applies global thresholds to all rows efficiently

-----------------------------------------------------------
*/

-- NOTE:
-- Recency threshold (6 months) is business-defined
-- and may vary depending on product lifecycle:
--   → Fast-moving goods: shorter threshold
--   → Durable goods: longer threshold

WITH threshold AS (
    SELECT TOP 1
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY total_sales)
        OVER () AS P25,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_sales)
        OVER () AS P50

    FROM gold.report_products
)

SELECT 
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.total_sales,
    p.lifespan,
    p.recency,
    t.P25,
    t.P50,

    -- Inventory risk classification
    CASE 
        WHEN p.total_sales < t.P25 AND p.recency > 6 THEN 'High Risk'
        WHEN p.total_sales < t.P50 AND p.recency > 6 THEN 'Medium Risk'
        ELSE 'Healthy'
    END AS inventory_status

FROM gold.report_products p
CROSS JOIN threshold t;