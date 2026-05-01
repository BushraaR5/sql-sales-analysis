/*
===========================================================
Analysis: Customer Spending Trend

Objective:
Analyze how individual customer spending evolves over time by:

- Calculating cumulative (running) total sales per customer
- Estimating short-term spending trends using rolling windows

-----------------------------------------------------------

Methodology:
1. Aggregate sales at order level per customer
2. Use window functions to compute:
    → Running total (lifetime spend progression)
    → Rolling 3-order total (short-term behavior)

-----------------------------------------------------------

Output:
- Customer
- Order details
- Running total spend
- Rolling spend (last 3 orders)

===========================================================
*/

/*
-----------------------------------------------------------
Design Decisions & Justification

1. Why aggregate at order level?
   - Ensures correct granularity for customer transactions
   - Avoids duplication from multiple product rows per order

2. Why use SUM() OVER (PARTITION BY customer ORDER BY order_date)?
   - Tracks cumulative spend progression over time
   - Helps identify high-value and growing customers

3. Why use ROWS BETWEEN 2 PRECEDING AND CURRENT ROW?
   - Captures last 3 transactions (not months)
   - More reliable since orders are not evenly spaced in time

4. Why not true "rolling 3-month"?
   - Orders are irregular (not monthly)
   - A time-based window would require continuous date series
   - Current approach = rolling transaction-based trend (more realistic)

-----------------------------------------------------------
*/

WITH base AS (
    SELECT
        c.customer_key AS customer,
        c.first_name + ' ' + c.last_name AS fullname,
        f.order_number,
        f.order_date,

        -- Aggregate at order level
        SUM(f.sales_amount) AS total_sales

    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key

    WHERE f.order_date IS NOT NULL

    GROUP BY
        c.customer_key,
        c.first_name + ' ' + c.last_name,
        f.order_number,
        f.order_date
)

SELECT
    customer,
    fullname,
    order_number,
    order_date,

    -- Running total (lifetime value progression)
    SUM(total_sales) OVER (
        PARTITION BY customer
        ORDER BY order_date
    ) AS running_total_by_customer,

    -- Rolling last 3 orders (short-term trend)
    SUM(total_sales) OVER (
        PARTITION BY customer
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling3_total_by_customer

FROM base
ORDER BY customer, order_date;