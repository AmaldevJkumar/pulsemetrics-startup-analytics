-- Load CSV data into raw tables
-- IMPORTANT: Update the file paths below to match your local system

-- Windows example paths (update these):
-- C:/Users/YourName/pulsemetrics/data_generation/output/users.csv
-- 
-- Note: Use forward slashes (/) even on Windows, or escape backslashes (\\)

-- Load users
\echo 'Loading users...'
COPY raw.users(
    user_id,
    email,
    first_name,
    last_name,
    company,
    job_title,
    country,
    acquisition_channel,
    signup_date,
    is_activated,
    created_at,
    updated_at
)
FROM 'C:/path/to/your/pulsemetrics/data_generation/output/users.csv'
DELIMITER ','
CSV HEADER;

-- Load sessions
\echo 'Loading sessions...'
COPY raw.sessions(
    session_id,
    user_id,
    session_start,
    session_end,
    duration_minutes,
    device_type,
    browser,
    pages_viewed,
    created_at
)
FROM 'C:/path/to/your/pulsemetrics/data_generation/output/sessions.csv'
DELIMITER ','
CSV HEADER;

-- Load events
\echo 'Loading events...'
COPY raw.events(
    event_id,
    session_id,
    user_id,
    event_type,
    event_timestamp,
    properties,
    created_at
)
FROM 'C:/path/to/your/pulsemetrics/data_generation/output/events.csv'
DELIMITER ','
CSV HEADER;

-- Load subscriptions
\echo 'Loading subscriptions...'
COPY raw.subscriptions(
    subscription_id,
    user_id,
    plan,
    status,
    started_at,
    ended_at,
    monthly_value,
    billing_cycle,
    is_trial,
    created_at,
    updated_at
)
FROM 'C:/path/to/your/pulsemetrics/data_generation/output/subscriptions.csv'
DELIMITER ','
CSV HEADER
NULL 'None';  -- Handle Python None values

-- Load payments
\echo 'Loading payments...'
COPY raw.payments(
    payment_id,
    subscription_id,
    user_id,
    amount,
    currency,
    status,
    payment_method,
    failure_reason,
    attempt_number,
    payment_date,
    created_at,
    updated_at
)
FROM 'C:/path/to/your/pulsemetrics/data_generation/output/payments.csv'
DELIMITER ','
CSV HEADER
NULL '';  -- Handle empty strings as NULL

-- Verify data loaded
\echo ''
\echo '✓ Data load complete! Verification:'
\echo ''

SELECT 'users' AS table_name, COUNT(*) AS row_count FROM raw.users
UNION ALL
SELECT 'sessions', COUNT(*) FROM raw.sessions
UNION ALL
SELECT 'events', COUNT(*) FROM raw.events
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM raw.subscriptions
UNION ALL
SELECT 'payments', COUNT(*) FROM raw.payments
ORDER BY table_name;

\echo ''
\echo 'Next step: Run dbt transformations'
