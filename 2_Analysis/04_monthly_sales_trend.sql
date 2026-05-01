/*
===========================================================
Analysis: Monthly Sales Trend & Growth

Objective:
Analyze how sales evolve over time and measure
month-over-month (MoM) growth to identify trends,
seasonality, and performance shifts.

-----------------------------------------------------------

Methodology:
1. Aggregate sales at monthly level
2. Use LAG() to get previous month’s sales
3. Calculate MoM growth %

-----------------------------------------------------------

Output:
- Year
- Month
- Total sales
- Previous month sales
- Month-over-month growth %
- Rolling 3 month average

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

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
        EOMONTH(order_date) AS month_end,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY EOMONTH(order_date)
),

final AS (
    SELECT 
        month_end,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month_end) AS prev_month_sales,
		AVG(total_sales) OVER (
            ORDER BY month_end
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_3m
    FROM monthly_sales
)

SELECT 
    month_end,
    total_sales,
    prev_month_sales,
    COALESCE(
    (total_sales - prev_month_sales) * 1.0 
    / NULLIF(prev_month_sales, 0),
    0
    ) AS mom_growth_pct,
	rolling_avg_3m
FROM final
ORDER BY month_end;