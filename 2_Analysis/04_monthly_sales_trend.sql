/*
===========================================================
📊 Analysis: Monthly Sales Trend & Growth

🧠 Objective:
Analyze how sales evolve over time and measure
month-over-month (MoM) growth to identify trends,
seasonality, and performance shifts.

-----------------------------------------------------------

⚙️ Methodology:
1. Aggregate sales at monthly level
2. Use LAG() to get previous month’s sales
3. Calculate MoM growth %

-----------------------------------------------------------

📈 Output:
- Year
- Month
- Total sales
- Previous month sales
- Month-over-month growth %

===========================================================
*/

/*
-----------------------------------------------------------
🧠 Design Decisions & Justification

1. Why use CTE?
   - Separates aggregation from window logic
   - Improves readability and maintainability

2. Why use LAG()?
   - Efficient way to access previous row (previous month)
   - Avoids self-joins

3. Why ORDER BY year, month?
   - Ensures correct chronological calculation
   - Required for accurate LAG results

4. Why not calculate everything in one query?
   - Mixing aggregation + window functions reduces clarity
   - CTE makes transformation pipeline clearer

-----------------------------------------------------------
*/

-- Alternative approaches:
-- 1. Direct aggregation + LAG in same query
-- 2. Subquery-based approach
-- CTE chosen for clarity and maintainability

WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
),

final AS (
    SELECT 
        year,
        month,
        total_sales,

        -- Previous month sales
        LAG(total_sales) OVER (
            ORDER BY year, month
        ) AS prev_month_sales

    FROM monthly_sales
)

SELECT 
    year,
    month,
    total_sales,
    prev_month_sales,

    -- MoM growth %
    (total_sales - prev_month_sales) * 1.0 
        / NULLIF(prev_month_sales, 0) AS mom_growth_pct

FROM final
ORDER BY year, month;