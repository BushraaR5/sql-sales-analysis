/*
===========================================================
Analysis: Top Products Within Each Category

Objective:
Identify the top 3 products within each category based on
total sales to understand product performance distribution.

-----------------------------------------------------------

Methodology:
1. Partition products by category
2. Rank products within each category using ROW_NUMBER()
3. Select top 3 products per category

-----------------------------------------------------------

Output:
- Category
- Product Name
- Total Sales
- Rank within category

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

1. Why use ROW_NUMBER()?
   - Ensures exactly top 3 products per category
   - Avoids returning more than 3 rows in case of ties

2. Why not use RANK() or DENSE_RANK()?
   - RANK() may return more than 3 rows if ties exist
   - Requirement is strict: "Top 3 per category"

3. Why PARTITION BY category?
   - Enables independent ranking within each category

4. Why not use CROSS APPLY as primary method?
   - CROSS APPLY is useful but less intuitive
   - Window functions are more scalable and readable

-----------------------------------------------------------
*/

WITH ranked_products AS (
    SELECT 
        category,
        product_name,
        total_sales,

        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY total_sales DESC
        ) AS rn

    FROM gold.report_products
)

SELECT 
    category,
    product_name,
    total_sales,
    rn AS rank_in_category

FROM ranked_products
WHERE rn <= 3
ORDER BY category, rn;

-- Alternative Approach: Using CROSS APPLY
-- Useful for top-N per group problems, but less flexible for ranking logic

-- SELECT c.category, p.product_name, p.total_sales
-- FROM (SELECT DISTINCT category FROM gold.report_products) c
-- CROSS APPLY (
--    SELECT TOP 3 product_name, total_sales
--    FROM gold.report_products p
--    WHERE p.category = c.category
--    ORDER BY total_sales DESC
-- ) p;