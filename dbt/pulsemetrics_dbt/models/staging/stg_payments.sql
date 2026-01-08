-- Staging model for payments
-- Cleans and enriches payment transaction data

WITH source AS (
    SELECT * FROM {{ source('raw', 'payments') }}
),

cleaned AS (
    SELECT
        payment_id,
        subscription_id,
        user_id,
        amount,
        UPPER(TRIM(currency)) AS currency,
        LOWER(TRIM(status)) AS status,
        LOWER(TRIM(payment_method)) AS payment_method,
        LOWER(TRIM(failure_reason)) AS failure_reason,
        attempt_number,
        payment_date,
        created_at,
        updated_at,
        
        -- Derived fields
        DATE(payment_date) AS payment_date_only,
        EXTRACT(YEAR FROM payment_date) AS payment_year,
        EXTRACT(MONTH FROM payment_date) AS payment_month,
        EXTRACT(QUARTER FROM payment_date) AS payment_quarter,
        
        -- Status flags
        CASE WHEN status = 'succeeded' THEN true ELSE false END AS is_successful,
        CASE WHEN status = 'failed' THEN true ELSE false END AS is_failed,
        CASE WHEN attempt_number > 1 THEN true ELSE false END AS is_retry,
        
        -- Payment method category
        CASE
            WHEN payment_method IN ('credit_card', 'debit_card') THEN 'card'
            WHEN payment_method = 'paypal' THEN 'digital_wallet'
            WHEN payment_method = 'bank_transfer' THEN 'bank'
            ELSE 'other'
        END AS payment_method_category,
        
        -- Risk indicators
        CASE
            WHEN attempt_number > 2 THEN 'high_risk'
            WHEN attempt_number = 2 THEN 'medium_risk'
            ELSE 'low_risk'
        END AS retry_risk_level
        
    FROM source
)

SELECT * FROM cleaned
