USE ROLE ROLE_LOADER;
USE WAREHOUSE MODERN_INSURANCE_PLATFORM_WH;

USE DATABASE PRD_MODERN_INSURANCE_PLATFORM;
USE SCHEMA RAW;

CREATE OR REPLACE TEMP TABLE TMP_PRD_POLICY_SCENARIO AS
WITH monthly_sales AS (
    SELECT
        COLUMN1::DATE AS month_start,
        COLUMN2::NUMBER AS sold_count,
        COLUMN3::FLOAT AS web_share
    FROM VALUES
        ('2023-01-01'::DATE, 32, 0.50),
        ('2023-02-01'::DATE, 34, 0.50),
        ('2023-03-01'::DATE, 36, 0.51),
        ('2023-04-01'::DATE, 38, 0.52),
        ('2023-05-01'::DATE, 40, 0.53),
        ('2023-06-01'::DATE, 42, 0.54),
        ('2023-07-01'::DATE, 44, 0.55),
        ('2023-08-01'::DATE, 46, 0.56),
        ('2023-09-01'::DATE, 48, 0.57),
        ('2023-10-01'::DATE, 50, 0.58),
        ('2023-11-01'::DATE, 52, 0.59),
        ('2023-12-01'::DATE, 54, 0.60),
        ('2024-01-01'::DATE, 56, 0.63),
        ('2024-02-01'::DATE, 58, 0.65),
        ('2024-03-01'::DATE, 60, 0.67),
        ('2024-04-01'::DATE, 62, 0.68),
        ('2024-05-01'::DATE, 64, 0.69),
        ('2024-06-01'::DATE, 66, 0.70),
        ('2024-07-01'::DATE, 68, 0.72),
        ('2024-08-01'::DATE, 70, 0.73),
        ('2024-09-01'::DATE, 72, 0.75),
        ('2024-10-01'::DATE, 74, 0.76),
        ('2024-11-01'::DATE, 76, 0.77),
        ('2024-12-01'::DATE, 78, 0.78)
),
month_ranges AS (
    SELECT
        month_start,
        sold_count,
        web_share,
        ROW_NUMBER() OVER (ORDER BY month_start) AS month_idx,
        COALESCE(
            SUM(sold_count) OVER (
                ORDER BY month_start
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) + 1 AS start_n,
        SUM(sold_count) OVER (ORDER BY month_start) AS end_n
    FROM monthly_sales
),
base AS (
    SELECT ROW_NUMBER() OVER (ORDER BY seq4()) AS n
    FROM TABLE(GENERATOR(ROWCOUNT => 1320))
),
mapped AS (
    SELECT
        b.n,
        r.month_start,
        r.sold_count,
        r.web_share,
        r.month_idx,
        b.n - r.start_n + 1 AS month_policy_n
    FROM base b
    JOIN month_ranges r
      ON b.n BETWEEN r.start_n AND r.end_n
),
scenario AS (
    SELECT
        n,
        month_start,
        sold_count,
        web_share,
        month_idx,
        month_policy_n,
        'C' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS customer_id,
        'P' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS policy_id,
        DATEADD(
            day,
            LEAST(
                DAY(LAST_DAY(month_start)) - 1,
                FLOOR(((month_policy_n - 1) * DAY(LAST_DAY(month_start))) / sold_count)
            ),
            month_start
        ) AS inception_date
    FROM mapped
)
SELECT
    n,
    customer_id,
    policy_id,
    month_start,
    month_idx,
    inception_date,
    DATEADD(day, 364, inception_date) AS expiry_date,
    DECODE(
        MOD(n, 20),
        0, 'MOTOR', 1, 'MOTOR', 2, 'MOTOR', 3, 'MOTOR', 4, 'MOTOR',
        5, 'MOTOR', 6, 'MOTOR', 7, 'MOTOR', 8, 'MOTOR',
        9, 'HOME', 10, 'HOME', 11, 'HOME', 12, 'HOME', 13, 'HOME', 14, 'HOME',
        15, 'TRAVEL', 16, 'TRAVEL',
        17, 'PET', 18, 'PET',
        'LIFE'
    ) AS product_code,
    ROUND(
        DECODE(
            MOD(n, 20),
            0, 720, 1, 735, 2, 750, 3, 765, 4, 780,
            5, 795, 6, 810, 7, 825, 8, 840,
            9, 470, 10, 485, 11, 500, 12, 515, 13, 530, 14, 545,
            15, 95, 16, 110,
            17, 185, 18, 210,
            390
        ) + (month_idx * 4.50) + MOD(n, 11) * 3.25,
        2
    ) AS annual_premium_num,
    CASE
        WHEN MOD(n, 100) < web_share * 100 THEN 'web'
        WHEN MOD(n, 100) < (web_share * 100) + 14 THEN 'broker'
        ELSE 'call_centre'
    END AS acquisition_channel,
    CASE
        WHEN month_idx <= 12 THEN MOD(n, 11) = 0
        ELSE MOD(n, 19) = 0
    END AS cancelled_flag,
    CASE
        WHEN month_idx <= 12 THEN MOD(n, 23) = 0
        ELSE MOD(n, 31) = 0
    END AS raw_lapse_flag,
    MOD(n, 4) = 0 AS mta_1_flag,
    MOD(n, 15) = 0 AS mta_2_flag
FROM scenario;

CREATE OR REPLACE TEMP TABLE TMP_PRD_POLICY_SCENARIO_FINAL AS
SELECT
    *,
    IFF(cancelled_flag, FALSE, raw_lapse_flag) AS lapsed_flag,
    IFF(cancelled_flag, 'CANCELLED', IFF(raw_lapse_flag, 'LAPSED', 'ACTIVE')) AS policy_status,
    CASE
        WHEN inception_date <= '2024-06-30'::DATE
             AND NOT cancelled_flag
             AND NOT raw_lapse_flag
        THEN TRUE
        ELSE FALSE
    END AS renewal_flag,
    CASE
        WHEN MOD(n, 20) <= 8 AND MOD(n, 6) = 0 THEN TRUE
        WHEN MOD(n, 20) BETWEEN 9 AND 14 AND MOD(n, 9) = 0 THEN TRUE
        WHEN MOD(n, 20) IN (17, 18) AND MOD(n, 10) = 0 THEN TRUE
        WHEN MOD(n, 20) IN (15, 16) AND MOD(n, 18) = 0 THEN TRUE
        WHEN MOD(n, 20) = 19 AND MOD(n, 25) = 0 THEN TRUE
        ELSE FALSE
    END AS claim_flag
FROM TMP_PRD_POLICY_SCENARIO;

INSERT INTO CUSTOMERS
    (CUSTOMER_ID, FIRST_NAME, LAST_NAME, DOB, EMAIL, CREATED_AT, SOURCE_SYSTEM, INGESTED_AT)
SELECT
    customer_id,
    DECODE(
        MOD(n, 16),
        0, 'Amelia', 1, 'Oliver', 2, 'Ava', 3, 'Noah',
        4, 'Isla', 5, 'Leo', 6, 'Mia', 7, 'Arthur',
        8, 'Freya', 9, 'Oscar', 10, 'Grace', 11, 'Theo',
        12, 'Ruby', 13, 'George', 14, 'Lily', 'Jack'
    ) AS first_name,
    DECODE(
        MOD(n, 16),
        0, 'Taylor', 1, 'Davies', 2, 'Patel', 3, 'Wilson',
        4, 'Evans', 5, 'Thomas', 6, 'Roberts', 7, 'Walker',
        8, 'Johnson', 9, 'Wright', 10, 'Lewis', 11, 'Hall',
        12, 'Allen', 13, 'Young', 14, 'King', 'Scott'
    ) AS last_name,
    TO_VARCHAR(
        DATEADD(
            day,
            MOD(n * 13, 365),
            DATEADD(year, -(23 + MOD(n, 33)), '2024-01-01'::DATE)
        ),
        'YYYY-MM-DD'
    ) AS dob,
    LOWER(customer_id) || '@exampleinsurance.co.uk' AS email,
    TO_VARCHAR(
        DATEADD(day, -(10 + MOD(n, 35)), inception_date),
        'YYYY-MM-DD'
    ) AS created_at,
    'CRM' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL;

INSERT INTO POLICIES
    (POLICY_ID, CUSTOMER_ID, PRODUCT_CODE, INCEPTION_DATE, EXPIRY_DATE, STATUS, ANNUAL_PREMIUM, SOURCE_SYSTEM, INGESTED_AT)
SELECT
    policy_id,
    customer_id,
    product_code,
    TO_VARCHAR(inception_date, 'YYYY-MM-DD') AS inception_date,
    TO_VARCHAR(expiry_date, 'YYYY-MM-DD') AS expiry_date,
    policy_status,
    TO_CHAR(annual_premium_num, 'FM9999990.00') AS annual_premium,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL;

INSERT INTO CLAIMS
    (CLAIM_ID, POLICY_ID, LOSS_DATE, REPORTED_DATE, CLAIM_STATUS, PAID_AMOUNT, SOURCE_SYSTEM, INGESTED_AT)
SELECT
    'CL' || LPAD(TO_VARCHAR(200000 + n), 6, '0') AS claim_id,
    policy_id,
    TO_VARCHAR(
        DATEADD(day, 45 + MOD(n * 7, 220), inception_date),
        'YYYY-MM-DD'
    ) AS loss_date,
    TO_VARCHAR(
        DATEADD(day, 47 + MOD(n * 7, 220) + MOD(n, 5), inception_date),
        'YYYY-MM-DD'
    ) AS reported_date,
    CASE
        WHEN MOD(n, 10) IN (0, 1, 2, 3, 4, 5, 6) THEN 'CLOSED'
        WHEN MOD(n, 10) IN (7, 8) THEN 'OPEN'
        ELSE 'REJECTED'
    END AS claim_status,
    TO_CHAR(
        ROUND(
            CASE
                WHEN product_code = 'MOTOR' THEN 900 + MOD(n, 9) * 275
                WHEN product_code = 'HOME' THEN 650 + MOD(n, 8) * 220
                WHEN product_code = 'PET' THEN 180 + MOD(n, 6) * 55
                WHEN product_code = 'TRAVEL' THEN 120 + MOD(n, 5) * 40
                ELSE 1500 + MOD(n, 7) * 450
            END,
            2
        ),
        'FM9999990.00'
    ) AS paid_amount,
    'CLAIMS_SYS' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL
WHERE claim_flag;

INSERT INTO BUSINESS_EVENTS
    (EVENT_ID, POLICY_ID, EVENT_TS, EVENT_TYPE, CHANNEL, GROSS_PREMIUM_CHANGE, EVENT_VERSION, SOURCE_SYSTEM, INGESTED_AT)
SELECT
    'Q' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(DATEADD(day, -(5 + MOD(n, 10)), inception_date), 'YYYY-MM-DD') || 'T09:00:00Z' AS event_ts,
    'quote' AS event_type,
    acquisition_channel AS channel,
    '0.00' AS gross_premium_change,
    '1' AS event_version,
    'QUOTE_ENGINE' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL

UNION ALL

SELECT
    'NB' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(inception_date, 'YYYY-MM-DD') || 'T10:00:00Z' AS event_ts,
    'new_business' AS event_type,
    acquisition_channel AS channel,
    TO_CHAR(annual_premium_num, 'FM9999990.00') AS gross_premium_change,
    '1' AS event_version,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL

UNION ALL

SELECT
    'M1' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(DATEADD(day, 95 + MOD(n, 20), inception_date), 'YYYY-MM-DD') || 'T11:30:00Z' AS event_ts,
    'mta' AS event_type,
    IFF(MOD(n, 3) = 0, 'broker', 'call_centre') AS channel,
    TO_CHAR(
        ROUND(IFF(MOD(n, 3) = 0, -12.50, 18 + MOD(n, 6) * 4.25), 2),
        'FM9999990.00'
    ) AS gross_premium_change,
    '1' AS event_version,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL
WHERE mta_1_flag

UNION ALL

SELECT
    'M2' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(DATEADD(day, 185 + MOD(n, 25), inception_date), 'YYYY-MM-DD') || 'T14:15:00Z' AS event_ts,
    'mta' AS event_type,
    'call_centre' AS channel,
    TO_CHAR(ROUND(10 + MOD(n, 5) * 3.50, 2), 'FM9999990.00') AS gross_premium_change,
    '2' AS event_version,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL
WHERE mta_2_flag

UNION ALL

SELECT
    'CN' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(DATEADD(day, 120 + MOD(n, 70), inception_date), 'YYYY-MM-DD') || 'T15:00:00Z' AS event_ts,
    'cancellation' AS event_type,
    'call_centre' AS channel,
    '0.00' AS gross_premium_change,
    '1' AS event_version,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL
WHERE cancelled_flag

UNION ALL

SELECT
    'LP' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(DATEADD(day, 7 + MOD(n, 14), expiry_date), 'YYYY-MM-DD') || 'T08:30:00Z' AS event_ts,
    'lapse' AS event_type,
    'web' AS channel,
    '0.00' AS gross_premium_change,
    '1' AS event_version,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL
WHERE lapsed_flag

UNION ALL

SELECT
    'RN' || LPAD(TO_VARCHAR(100000 + n), 6, '0') AS event_id,
    policy_id,
    TO_VARCHAR(DATEADD(day, 1, expiry_date), 'YYYY-MM-DD') || 'T10:30:00Z' AS event_ts,
    'renewal' AS event_type,
    'web' AS channel,
    TO_CHAR(ROUND(22 + MOD(n, 8) * 3.25, 2), 'FM9999990.00') AS gross_premium_change,
    '1' AS event_version,
    'POLICY_ADMIN' AS source_system,
    CURRENT_TIMESTAMP() AS ingested_at
FROM TMP_PRD_POLICY_SCENARIO_FINAL
WHERE renewal_flag;
