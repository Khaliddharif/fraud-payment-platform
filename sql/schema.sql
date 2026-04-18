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
