/*
===========================================================
📊 Analysis: Customer Lifetime Value (LTV) Ranking

🧠 Objective:
Identify high-value customers based on their efficiency as
long-term spenders using:

    Lifetime Value = total_sales / lifespan

This measures how much revenue a customer generates per unit
of time.

-----------------------------------------------------------

⚙️ Methodology:
- Calculate lifetime value using total_sales and lifespan
- Rank customers based on LTV (descending)
- Handle division-by-zero safely using NULLIF()

-----------------------------------------------------------

📈 Output:
- Customer details
- Lifetime value (LTV)
- Ranking based on LTV

===========================================================
*/

/*
-----------------------------------------------------------
🧠 Design Decisions & Justification

1. Why use total_sales / lifespan?
   - Captures spending efficiency over time
   - Identifies customers who generate high revenue quickly

2. Why use NULLIF(lifespan, 0)?
   - Prevents division-by-zero errors
   - Returns NULL for customers with zero lifespan

3. Why use RANK() instead of ROW_NUMBER()?
   - Allows equal LTV values to share the same rank
   - More appropriate for analytical ranking

4. Why not filter out lifespan = 0?
   - Keeping them allows visibility into new customers
   - NULL LTV naturally pushes them to the bottom

-----------------------------------------------------------
*/

-- NOTE:
-- LTV is sensitive to lifespan duration.
-- Customers with very short lifespan (e.g., new customers)
-- may appear artificially high-value.
-- In real scenarios, consider:
--   → minimum lifespan threshold
--   → or combining with total_sales

SELECT
    customer,
    fullname,
    total_sales,
    lifespan,

    -- Lifetime Value (revenue per time unit)
    total_sales * 1.0 / NULLIF(lifespan, 0) AS lifetime_value,

    -- Rank customers by LTV
    RANK() OVER (
        ORDER BY total_sales * 1.0 / NULLIF(lifespan, 0) DESC
    ) AS lifetime_value_rank

FROM gold.report_customers
ORDER BY lifetime_value_rank;