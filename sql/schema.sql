-- Fraud Payment Platform Schema
-- Azure SQL

CREATE TABLE accounts (
    account_id        BIGINT PRIMARY KEY,
    account_type      VARCHAR(20),
    created_at        DATETIME2,
    country_code      CHAR(2),
    risk_tier         VARCHAR(10),
    kyc_level         VARCHAR(10),
    is_active         BIT
);

CREATE TABLE transactions (
    transaction_id          BIGINT PRIMARY KEY,
    transaction_time        DATETIME2,
    transaction_type        VARCHAR(20),
    amount                  DECIMAL(18,2),
    currency                CHAR(3),
    origin_account_id       BIGINT,
    destination_account_id  BIGINT,
    channel                 VARCHAR(20),
    status                  VARCHAR(20),
    risk_score              INT,
    is_fraud                BIT,
    created_at              DATETIME2,
    CONSTRAINT fk_origin_account
        FOREIGN KEY (origin_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_destination_account
        FOREIGN KEY (destination_account_id) REFERENCES accounts(account_id)
);

CREATE TABLE sessions (
    session_id      BIGINT PRIMARY KEY,
    account_id      BIGINT,
    device_id       VARCHAR(100),
    ip_address      VARCHAR(45),
    country_code    CHAR(2),
    device_type     VARCHAR(20),
    first_seen      DATETIME2,
    last_seen       DATETIME2,
    CONSTRAINT fk_session_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE merchants (
    merchant_id       BIGINT PRIMARY KEY,
    merchant_category VARCHAR(50),
    country_code      CHAR(2),
    risk_level        VARCHAR(10)
);

CREATE TABLE fraud_rules (
    rule_id      INT PRIMARY KEY,
    rule_name    VARCHAR(100),
    description  VARCHAR(255),
    is_active    BIT
);

CREATE TABLE fraud_alerts (
    alert_id        BIGINT PRIMARY KEY,
    transaction_id  BIGINT,
    rule_id         INT,
    alert_time      DATETIME2,
    risk_score      INT,
    decision        VARCHAR(20),
    resolution      VARCHAR(20),
    CONSTRAINT fk_alert_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_alert_rule
        FOREIGN KEY (rule_id) REFERENCES fraud_rules(rule_id)
);

CREATE TABLE account_activity_hourly (
    account_id            BIGINT,
    window_start          DATETIME2,
    transaction_count     INT,
    total_amount          DECIMAL(18,2),
    distinct_destinations INT,
    avg_amount            DECIMAL(18,2),
    PRIMARY KEY (account_id, window_start)
);


;WITH numbers AS (
    SELECT TOP (1200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO accounts (
    account_id,
    account_type,
    created_at,
    country_code,
    risk_tier,
    kyc_level,
    is_active
)
SELECT
    n AS account_id,

    -- Mostly individuals, some businesses
    CASE 
        WHEN n % 10 = 0 THEN 'business' 
        ELSE 'individual' 
    END AS account_type,

    -- Account age: between today and ~2.5 years ago
    DATEADD(day, -(n % 900), GETDATE()) AS created_at,

    -- Country distribution
    CASE 
        WHEN n % 3 = 0 THEN 'FR'
        WHEN n % 3 = 1 THEN 'DE'
        ELSE 'ES'
    END AS country_code,

    -- Risk tiers
    CASE 
        WHEN n % 15 = 0 THEN 'high'
        WHEN n % 5  = 0 THEN 'medium'
        ELSE 'low'
    END AS risk_tier,

    -- KYC levels
    CASE 
        WHEN n % 12 = 0 THEN 'none'
        WHEN n % 4  = 0 THEN 'basic'
        ELSE 'full'
    END AS kyc_level,

    1 AS is_active
FROM numbers;


SELECT COUNT(*) AS total_accounts FROM accounts;


SELECT TOP 20 *
FROM accounts
ORDER BY created_at DESC;


;WITH numbers AS (
    SELECT TOP (10000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO transactions (
    transaction_id,
    transaction_time,
    transaction_type,
    amount,
    currency,
    origin_account_id,
    destination_account_id,
    channel,
    status,
    risk_score,
    is_fraud,
    created_at
)
SELECT
    n AS transaction_id,

    -- Spread transactions over time (most recent first)
    DATEADD(minute, -n, GETDATE()) AS transaction_time,

    -- Mostly payments, some transfers
    CASE 
        WHEN n % 5 = 0 THEN 'transfer'
        ELSE 'payment'
    END AS transaction_type,

    -- Fraudulent transactions have much higher amounts
    CASE 
        WHEN n % 50 = 0 THEN 3000 + (n % 2000)
        ELSE 5 + (n % 250)
    END AS amount,

    'EUR' AS currency,

    -- Pick origin & destination accounts
    (n % 1200) + 1 AS origin_account_id,
    ((n + 17) % 1200) + 1 AS destination_account_id,

    -- Channels
    CASE 
        WHEN n % 3 = 0 THEN 'mobile'
        WHEN n % 3 = 1 THEN 'web'
        ELSE 'api'
    END AS channel,

    -- Fraud often gets blocked
    CASE 
        WHEN n % 50 = 0 THEN 'blocked'
        ELSE 'approved'
    END AS status,

    -- Higher risk score for fraud
    CASE 
        WHEN n % 50 = 0 THEN 80 + (n % 20)
        ELSE 5 + (n % 40)
    END AS risk_score,

    -- Fraud label (~2%)
    CASE 
        WHEN n % 50 = 0 THEN 1
        ELSE 0
    END AS is_fraud,

    GETDATE() AS created_at
FROM numbers;



SELECT COUNT(*) AS total_transactions
FROM transactions;


SELECT
    COUNT(*) AS total_tx,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_tx,
    CAST(
        100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS fraud_rate_pct
FROM transactions;

SELECT TOP 20 *
FROM transactions
ORDER BY risk_score DESC;

