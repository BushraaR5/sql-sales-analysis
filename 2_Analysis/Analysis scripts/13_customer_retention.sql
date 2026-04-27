/*
===========================================================
📊 Analysis: Customer Retention Ratio

🧠 Objective:
Measure customer retention by evaluating how consistently
customers make purchases over their active lifespan.

Retention Ratio =
    months_active / total_possible_months

-----------------------------------------------------------

⚙️ Methodology:
1. Convert order dates to monthly granularity
2. Calculate:
    → Months active (distinct months with purchases)
    → Total possible months (first → last purchase span)
3. Compute retention ratio

-----------------------------------------------------------

📈 Output:
- Customer details
- Months active
- Total months
- Retention ratio

===========================================================
*/

/*
-----------------------------------------------------------
🧠 Design Decisions & Justification

1. Why use EOMONTH()?
   - Normalizes all transactions to monthly level
   - Avoids duplicate counting within same month

2. Why COUNT(DISTINCT order_month)?
   - Measures actual engagement (active months)

3. Why DATEDIFF(month, MIN, MAX) + 1?
   - Captures full active period
   - +1 ensures inclusive counting

4. Why retention ratio?
   - Reflects consistency of customer engagement
   - Higher ratio → more loyal behavior

-----------------------------------------------------------
*/

-- NOTE:
-- Customers with only one month of activity will have
-- retention_ratio = 1, which may overstate engagement.
-- Consider filtering:
--   WHERE total_months > 1
-- for more meaningful retention analysis

WITH base AS (
    SELECT
        c.customer_key AS customer,
        c.first_name + ' ' + c.last_name AS fullname,
        EOMONTH(f.order_date) AS order_month
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
)

SELECT
    customer,
    fullname,

    -- Active months (engagement)
    COUNT(DISTINCT order_month) AS months_active,

    -- Total possible months
    DATEDIFF(month, MIN(order_month), MAX(order_month)) + 1 AS total_months,

    -- Retention ratio
    COUNT(DISTINCT order_month) * 1.0 
    / NULLIF(
        DATEDIFF(month, MIN(order_month), MAX(order_month)) + 1,
        0
    ) AS retention_ratio

FROM base
GROUP BY customer, fullname
ORDER BY retention_ratio DESC;