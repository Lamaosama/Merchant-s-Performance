WITH merchant_summary AS (
    SELECT 
        t.mid,
        m.store_name,
        COUNT(DISTINCT t.transaction_id) AS total_transactions,
        SUM(t.amount) AS total_revenue,
        COUNT(DISTINCT t.customer_id) AS unique_customers,
        AVG(r.rating) AS avg_rating,
        DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS revenue_rank
    FROM transactions t
    JOIN merchants m ON t.mid = m.mid_trx
    LEFT JOIN merchant_reviews r ON t.mid = r.mid
    WHERE t.transaction_date >= DATEADD(MONTH, -3, GETDATE())  -- Last 3 months
    GROUP BY t.mid, m.store_name
)
SELECT 
    ms.mid,
    ms.store_name,
    ms.total_transactions,
    ms.total_revenue,
    ms.unique_customers,
    ms.avg_rating,
    ms.revenue_rank,
    (ms.total_revenue / NULLIF(SUM(ms.total_revenue) OVER(), 0)) * 100 AS revenue_percentage
FROM merchant_summary ms
ORDER BY total_revenue DESC;