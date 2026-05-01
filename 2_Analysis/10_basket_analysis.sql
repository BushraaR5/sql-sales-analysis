/*
===========================================================
Analysis: Product Basket Analysis (Association Rules)

Objective:
Identify frequently co-purchased product pairs and evaluate
their relationships using:

- Support
- Confidence
- Lift

Used to power product recommendations and bundling strategies.

-----------------------------------------------------------

Methodology:
1. Create product-level transaction dataset
2. Generate product pairs using self-join
3. Calculate:
    → Support (co-occurrence frequency)
    → Confidence (conditional probability)
    → Lift (strength of association)

-----------------------------------------------------------

Output:
- Product pairs
- Support, Confidence, Lift
- Recommendation flag

===========================================================
*/

/*
-----------------------------------------------------------
esign Decisions & Justification

1. Why self-join on order_number?
   - Identifies products purchased together in same transaction

2. Why use product_key < product_key?
   - Avoids duplicate pairs (A,B) and (B,A)
   - Integer comparison is more efficient than string comparison

3. Why COUNT(DISTINCT order_number)?
   - Ensures each order contributes once per pair

4. Why use lift?
   - Lift > 1 → positive association
   - Lift = 1 → independent
   - Lift < 1 → negative association

-----------------------------------------------------------
*/

-- NOTE:
-- Thresholds (support > 0.01, confidence > 0.3, lift > 1.2)
-- are business-defined and can be tuned based on:
--   → dataset size
--   → product diversity
--   → business goals

WITH base AS (
    SELECT
        f.order_number,
        p.product_key,
        p.product_name
    FROM gold.fact_sales f
    JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

pairs AS (
    SELECT
        b1.product_key AS product_key_1,
        b2.product_key AS product_key_2,
        b1.product_name AS product_name_1,
        b2.product_name AS product_name_2,

        COUNT(DISTINCT b1.order_number) AS pair_count

    FROM base b1
    JOIN base b2
        ON b1.order_number = b2.order_number
        AND b1.product_key < b2.product_key

    GROUP BY 
        b1.product_key,
        b2.product_key,
        b1.product_name,
        b2.product_name
),

product_freq AS (
    SELECT
        product_key,
        COUNT(DISTINCT order_number) AS product_count
    FROM base
    GROUP BY product_key
),

total_orders AS (
    SELECT COUNT(DISTINCT order_number) AS total_orders
    FROM base
),

final AS (
    SELECT
        p.product_name_1,
        p.product_name_2,

        -- Support
        p.pair_count * 1.0 / t.total_orders AS support,

        -- Confidence
        p.pair_count * 1.0 / pf1.product_count AS confidence_A_to_B,
        p.pair_count * 1.0 / pf2.product_count AS confidence_B_to_A,

        -- Lift
        (p.pair_count * 1.0 / t.total_orders) /
        (
            (pf1.product_count * 1.0 / t.total_orders) *
            (pf2.product_count * 1.0 / t.total_orders)
        ) AS lift

    FROM pairs p
    JOIN product_freq pf1 ON p.product_key_1 = pf1.product_key
    JOIN product_freq pf2 ON p.product_key_2 = pf2.product_key
    CROSS JOIN total_orders t
)

-- Final filtered recommendations
SELECT
    product_name_1,
    product_name_2,
    support,
    confidence_A_to_B,
    confidence_B_to_A,
    lift,

    CASE
        WHEN (confidence_A_to_B > 0.3 OR confidence_B_to_A > 0.3)
             AND lift > 1.2
             AND support > 0.01
        THEN 'Recommended'
        ELSE 'Ignore'
    END AS recommendation_flag

FROM final
ORDER BY lift DESC;