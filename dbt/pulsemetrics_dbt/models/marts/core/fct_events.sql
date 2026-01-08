-- Event facts for user interaction analysis
-- Captures all user events with dimensional context

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
),

users AS (
    SELECT
        user_id,
        acquisition_channel,
        signup_date,
        is_activated
    FROM {{ ref('dim_users') }}
),

sessions AS (
    SELECT
        session_id,
        device_type,
        browser,
        is_engaged_session
    FROM {{ ref('stg_sessions') }}
),

final AS (
    SELECT
        e.event_id,
        e.session_id,
        e.user_id,
        e.event_type,
        e.event_category,
        e.event_timestamp,
        e.event_date,
        e.event_hour,
        e.engagement_score,
        e.properties,
        
        -- Dimensional attributes
        u.acquisition_channel,
        u.is_activated AS user_is_activated,
        s.device_type,
        s.browser,
        s.is_engaged_session,
        
        -- Derived metrics
        EXTRACT(DAY FROM (e.event_timestamp - u.signup_date)) AS days_since_signup,
        
        -- Date key for joining to date dimension
        TO_CHAR(e.event_date, 'YYYYMMDD')::INTEGER AS date_key,
        
        e.created_at,
        CURRENT_TIMESTAMP AS dbt_updated_at
        
    FROM events e
    INNER JOIN users u ON e.user_id = u.user_id
    INNER JOIN sessions s ON e.session_id = s.session_id
)

SELECT * FROM final
