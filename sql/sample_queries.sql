SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    CAST(
        100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS fraud_rate_pct,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END) AS fraud_amount
FROM transactions;



SELECT
    CASE
        WHEN risk_score < 20 THEN 'Low'
        WHEN risk_score < 50 THEN 'Medium'
        ELSE 'High'
    END AS risk_bucket,
    COUNT(*) AS transactions,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_cases
FROM transactions
GROUP BY
    CASE
        WHEN risk_score < 20 THEN 'Low'
        WHEN risk_score < 50 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY risk_bucket;



SELECT
    channel,
    COUNT(*) AS transactions,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    CAST(
        100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS fraud_rate_pct
FROM transactions
GROUP BY channel
ORDER BY fraud_rate_pct DESC;



SELECT
    CASE
        WHEN DATEDIFF(day, a.created_at, t.transaction_time) < 30 THEN 'New (<30d)'
        WHEN DATEDIFF(day, a.created_at, t.transaction_time) < 180 THEN 'Mid (1–6m)'
        ELSE 'Old (>6m)'
    END AS account_age_bucket,
    COUNT(*) AS transactions,
    SUM(CASE WHEN t.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_cases
FROM transactions t
JOIN accounts a
    ON t.origin_account_id = a.account_id
GROUP BY
    CASE
        WHEN DATEDIFF(day, a.created_at, t.transaction_time) < 30 THEN 'New (<30d)'
        WHEN DATEDIFF(day, a.created_at, t.transaction_time) < 180 THEN 'Mid (1–6m)'
        ELSE 'Old (>6m)'
    END
ORDER BY fraud_cases DESC;


SELECT
    status,
    COUNT(*) AS transactions,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END) AS fraud_amount
FROM transactions
GROUP BY status;
