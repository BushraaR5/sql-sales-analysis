/*
===========================================================
Analysis: Product Contribution to Total Revenue

Objective:
Determine how much each product contributes to the
total revenue and identify key products driving performance.

-----------------------------------------------------------

Methodology:
1. Calculate total revenue using window function
2. Compute each product’s % contribution in total revenue
3. Calculate cumulative % contribution to identify top contributors

-----------------------------------------------------------

Output:
- Product details
- total revenue
- % contribution
- Cumulative % contribution (Pareto across all products)

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

1. Why use window functions instead of GROUP BY?
   - Allows calculation of totals without collapsing rows
   - Enables per-product contribution analysis

2. Why cumulative %?
   - Helps identify top products contributing to X% of revenue (e.g., 80%)
   - Enables Pareto-style analysis within each category

4. Why ROWS instead of default RANGE?
   - Ensures row-by-row accumulation even when total_sales values repeat

-----------------------------------------------------------
*/

-- revenue by products
SELECT
    product_key,
    product_name,
    total_sales,

    -- Total revenue (global)
    SUM(total_sales) OVER () AS total_revenue,

    -- % contribution (global)
    total_sales * 1.0 / 
    SUM(total_sales) OVER () AS pct_revenue,

    -- Cumulative % (Pareto across all products)
    SUM(total_sales) OVER (
        ORDER BY total_sales DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) * 1.0 /
    SUM(total_sales) OVER () AS cumulative_pct

FROM gold.report_products
ORDER BY total_sales DESC;

-- category revenue contribution
-- SELECT
--     product_key,
--     product_name,
--     category,
--     subcategory,
--     total_sales,

--     -- Total revenue within category
--     SUM(total_sales) OVER (
--         PARTITION BY category
--     ) AS total_revenue_by_category,

--     -- % contribution of each product
--     total_sales * 1.0 /
--     SUM(total_sales) OVER (PARTITION BY category) AS pct_revenue_by_category,

--     -- Cumulative % contribution (Pareto within category)
--     SUM(total_sales) OVER (
--         PARTITION BY category
--         ORDER BY total_sales DESC
--         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--     ) * 1.0 /
--     SUM(total_sales) OVER (PARTITION BY category) AS cumulative_pct

-- FROM gold.report_products
-- ORDER BY category, total_sales DESC;

-- Identify products contributing to top 80% of category revenue

-- WITH contribution AS (
--    SELECT
--        product_name,
--        category,
--        total_sales,

--        SUM(total_sales) OVER (
--            PARTITION BY category
--            ORDER BY total_sales DESC
--            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--        ) * 1.0 /
--        SUM(total_sales) OVER (PARTITION BY category) AS cumulative_pct

--    FROM gold.report_products
-- )

-- SELECT *
-- FROM contribution
-- WHERE cumulative_pct <= 0.8
-- ORDER BY category, cumulative_pct;

