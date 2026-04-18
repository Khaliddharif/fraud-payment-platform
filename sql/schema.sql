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
