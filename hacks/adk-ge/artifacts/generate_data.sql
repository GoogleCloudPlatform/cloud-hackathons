-- BigQuery SQL Script to generate mock retail banking data.

-- Set up previous quarter start and end dates dynamically
DECLARE today DATE DEFAULT CURRENT_DATE();
DECLARE prev_q_start DATE;
DECLARE prev_q_end DATE;

SET prev_q_start = DATE_TRUNC(DATE_SUB(today, INTERVAL 3 MONTH), QUARTER);
SET prev_q_end = LAST_DAY(DATE_SUB(today, INTERVAL 3 MONTH), QUARTER);

-- ==========================================
-- 1. Create and populate the CUSTOMERS table
-- ==========================================
CREATE OR REPLACE TABLE `retail_banking.customers`
OPTIONS(
  description = "Retail banking customer profiles, containing demographic information and join dates."
) AS
WITH raw_data AS (
  SELECT
    id AS customer_id,
    -- Deterministic pseudorandom values using FARM_FINGERPRINT for reproducibility
    ABS(MOD(FARM_FINGERPRINT(CAST(id AS STRING)), 100)) AS rand_pct,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_age')), 100)) AS rand_age,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_gender')), 100)) AS rand_gender,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_region')), 4)) AS rand_region,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_join')), 1621)) AS rand_join_days
  FROM UNNEST(GENERATE_ARRAY(1, 1000)) AS id
),
customers_pre AS (
  SELECT
    customer_id,
    CASE
      WHEN rand_pct < 40 THEN 18 + MOD(rand_age, 18) -- young: 18 to 35
      WHEN rand_pct < 80 THEN 36 + MOD(rand_age, 25) -- middle: 36 to 60
      ELSE 61 + MOD(rand_age, 25)                    -- senior: 61 to 85
    END AS age,
    CASE
      WHEN rand_gender < 48 THEN 'M'
      WHEN rand_gender < 96 THEN 'F'
      ELSE 'U'
    END AS gender,
    CASE rand_region
      WHEN 0 THEN 'Amsterdam'
      WHEN 1 THEN 'Utrecht'
      WHEN 2 THEN 'Rotterdam'
      ELSE 'Groningen'
    END AS region,
    -- Join date in last 5 years: today - (180 + rand_join_days)
    DATE_SUB(today, INTERVAL (180 + rand_join_days) DAY) AS join_date
  FROM raw_data
)
SELECT customer_id, age, gender, region, join_date FROM customers_pre;


-- ==============================================
-- 2. Create and populate the CORE_ACCOUNTS_V2 table
-- ==============================================
CREATE OR REPLACE TABLE `retail_banking.core_accounts_v2`
OPTIONS(
  description = "Core deposit accounts representing products held by customers, with balances and statuses."
) AS

-- PART 1: First 1000 accounts (one for each customer)
WITH part1_raw AS (
  SELECT
    id AS account_id,
    id AS customer_id,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_actype')), 100)) AS rand_actype,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_opendate')), 31)) AS rand_open_days,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_balance')), 1000000)) / 1000000.0 AS rand_balance,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_status')), 100)) AS rand_status,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_last_txn')), 101)) AS rand_txn_days
  FROM UNNEST(GENERATE_ARRAY(1, 1000)) AS id
),
part1 AS (
  SELECT
    p.account_id,
    p.customer_id,
    c.join_date,
    -- If customer joined in previous quarter, force AP. Else, AP (10%), BS (40%), SC (50%)
    CASE
      WHEN c.join_date BETWEEN prev_q_start AND prev_q_end THEN 'AP'
      WHEN p.rand_actype < 10 THEN 'AP'
      WHEN p.rand_actype < 50 THEN 'BS'
      ELSE 'SC'
    END AS account_type,
    p.rand_open_days,
    p.rand_balance,
    p.rand_status,
    p.rand_txn_days
  FROM part1_raw p
  JOIN `retail_banking.customers` c ON p.customer_id = c.customer_id
),
part1_processed AS (
  SELECT
    account_id,
    customer_id,
    account_type,
    -- open_date: join_date + rand_open_days
    DATE_ADD(join_date, INTERVAL rand_open_days DAY) AS open_date,
    -- balance: AP [5000, 150000], BS [100, 20000], SC [50, 10000]
    ROUND(
      CASE
        WHEN account_type = 'AP' THEN 5000 + (150000 - 5000) * rand_balance
        WHEN account_type = 'BS' THEN 100 + (20000 - 100) * rand_balance
        ELSE 50 + (10000 - 50) * rand_balance
      END,
      2
    ) AS balance,
    CASE WHEN rand_status < 92 THEN 'Active' ELSE 'Closed' END AS status,
    rand_txn_days
  FROM part1
),
part1_final AS (
  SELECT
    account_id,
    customer_id,
    account_type,
    CAST(balance AS FLOAT64) AS balance,
    open_date,
    status,
    CASE
      WHEN status = 'Active' THEN
        LEAST(DATE_ADD(open_date, INTERVAL rand_txn_days DAY), today)
      ELSE NULL
    END AS last_transaction_date
  FROM part1_processed
),

-- PART 2: Remaining 500 accounts
part2_raw AS (
  SELECT
    id AS account_id,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_cust')), 1000)) + 1 AS customer_id,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_actype')), 100)) AS rand_actype,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_ap_pq')), 100)) AS rand_ap_pq,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_pq_days')), DATE_DIFF(prev_q_end, prev_q_start, DAY) + 1)) AS rand_pq_days,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_norm_days')), 501)) AS rand_norm_days,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_future_cap')), 31)) AS rand_future_cap,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_balance')), 1000000)) / 1000000.0 AS rand_balance,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_status')), 100)) AS rand_status,
    ABS(MOD(FARM_FINGERPRINT(CONCAT(CAST(id AS STRING), '_last_txn')), 101)) AS rand_txn_days
  FROM UNNEST(GENERATE_ARRAY(1001, 1500)) AS id
),
part2 AS (
  SELECT
    p.account_id,
    p.customer_id,
    c.join_date,
    CASE
      WHEN p.rand_actype < 40 THEN 'AP'
      WHEN p.rand_actype < 70 THEN 'BS'
      ELSE 'SC'
    END AS account_type,
    p.rand_ap_pq,
    p.rand_pq_days,
    p.rand_norm_days,
    p.rand_future_cap,
    p.rand_balance,
    p.rand_status,
    p.rand_txn_days
  FROM part2_raw p
  JOIN `retail_banking.customers` c ON p.customer_id = c.customer_id
),
part2_processed AS (
  SELECT
    account_id,
    customer_id,
    account_type,
    CASE
      WHEN
        (CASE
          WHEN account_type = 'AP' AND rand_ap_pq < 60 THEN
            DATE_ADD(prev_q_start, INTERVAL rand_pq_days DAY)
          ELSE
            DATE_ADD(join_date, INTERVAL rand_norm_days DAY)
        END) > today
      THEN
        DATE_SUB(today, INTERVAL rand_future_cap DAY)
      ELSE
        (CASE
          WHEN account_type = 'AP' AND rand_ap_pq < 60 THEN
            DATE_ADD(prev_q_start, INTERVAL rand_pq_days DAY)
          ELSE
            DATE_ADD(join_date, INTERVAL rand_norm_days DAY)
        END)
    END AS open_date,
    ROUND(
      CASE
        WHEN account_type = 'AP' THEN 5000 + (150000 - 5000) * rand_balance
        WHEN account_type = 'BS' THEN 100 + (20000 - 100) * rand_balance
        ELSE 50 + (10000 - 50) * rand_balance
      END,
      2
    ) AS balance,
    CASE WHEN rand_status < 90 THEN 'Active' ELSE 'Closed' END AS status,
    rand_txn_days
  FROM part2
),
part2_final AS (
  SELECT
    account_id,
    customer_id,
    account_type,
    CAST(balance AS FLOAT64) AS balance,
    open_date,
    status,
    CASE
      WHEN status = 'Active' THEN
        LEAST(DATE_ADD(open_date, INTERVAL rand_txn_days DAY), today)
      ELSE NULL
    END AS last_transaction_date
  FROM part2_processed
),

-- Combine both parts
combined AS (
  SELECT * FROM part1_final
  UNION ALL
  SELECT * FROM part2_final
)
SELECT
  account_id,
  customer_id,
  account_type,
  balance,
  open_date,
  status,
  last_transaction_date
FROM combined
ORDER BY account_id;


-- ==============================================================================
-- 3. Set COLUMN descriptions for the created tables
-- ==============================================================================

-- Column descriptions for CUSTOMERS table
ALTER TABLE `retail_banking.customers`
  ALTER COLUMN customer_id SET OPTIONS(description="Unique identifier for the customer.");

ALTER TABLE `retail_banking.customers`
  ALTER COLUMN age SET OPTIONS(description="Customer age in years.");

ALTER TABLE `retail_banking.customers`
  ALTER COLUMN gender SET OPTIONS(description="Customer gender code (M = Male, F = Female, U = Unknown).");

ALTER TABLE `retail_banking.customers`
  ALTER COLUMN region SET OPTIONS(description="Geographic region of the customer's branch location.");

ALTER TABLE `retail_banking.customers`
  ALTER COLUMN join_date SET OPTIONS(description="The date the customer joined the retail bank.");


-- Column descriptions for CORE_ACCOUNTS_V2 table
ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN account_id SET OPTIONS(description="Unique identifier for the account.");

ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN customer_id SET OPTIONS(description="Foreign key referencing the customer who owns this account.");

ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN account_type SET OPTIONS(description="The account product type code.");

ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN balance SET OPTIONS(description="Current ledger balance of the account in EUR.");

ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN open_date SET OPTIONS(description="The date the account was officially opened.");

ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN status SET OPTIONS(description="The current status of the account (Active, Closed).");

ALTER TABLE `retail_banking.core_accounts_v2`
  ALTER COLUMN last_transaction_date SET OPTIONS(description="The date of the last financial transaction on this account (NULL for closed or inactive accounts).");

