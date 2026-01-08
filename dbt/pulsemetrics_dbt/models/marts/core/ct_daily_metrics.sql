-- Daily aggregated metrics for KPI tracking
-- Provides a single source of truth for daily business metrics

WITH date_spine AS (
    SELECT DISTINCT date
    FROM {{ ref('dim_date') }}
    WHERE date >= '2023-01-01' AND date <= CURRENT_DATE
),

daily_users AS (
    SELECT
        DATE(event_timestamp) AS date,
        COUNT(DISTINCT user_id) AS daily_active_users
    FROM {{ ref('stg_events') }}
    GROUP BY DATE(event_timestamp)
),

daily_signups AS (
    SELECT
        signup_date_only AS date,
        COUNT(*) AS new_signups,
        SUM(CASE WHEN is_activated THEN 1 ELSE 0 END) AS activated_users
    FROM {{ ref('stg_users') }}
    GROUP BY signup_date_only
),

daily_sessions AS (
    SELECT
        session_date AS date,
        COUNT(*) AS total_sessions,
        SUM(duration_minutes) AS total_session_minutes,
        AVG(duration_minutes) AS avg_session_duration,
        SUM(CASE WHEN is_engaged_session THEN 1 ELSE 0 END) AS engaged_sessions
    FROM {{ ref('stg_sessions') }}
    GROUP BY session_date
),

daily_events AS (
    SELECT
        event_date AS date,
        COUNT(*) AS total_events,
        COUNT(DISTINCT user_id) AS users_with_events,
        SUM(engagement_score) AS total_engagement_score
    FROM {{ ref('stg_events') }}
    GROUP BY event_date
),

daily_subscriptions AS (
    SELECT
        start_date AS date,
        COUNT(*) AS new_subscriptions,
        SUM(monthly_value) AS new_subscription_value,
        SUM(CASE WHEN is_trial THEN 1 ELSE 0 END) AS new_trials,
        SUM(CASE WHEN NOT is_trial THEN 1 ELSE 0 END) AS new_paid_subscriptions
    FROM {{ ref('stg_subscriptions') }}
    GROUP BY start_date
),

daily_churn AS (
    SELECT
        end_date AS date,
        COUNT(*) AS churned_subscriptions,
        SUM(monthly_value) AS churned_value
    FROM {{ ref('stg_subscriptions') }}
    WHERE is_churned
    GROUP BY end_date
),

daily_payments AS (
    SELECT
        payment_date_only AS date,
        COUNT(*) AS total_payments,
        SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) AS successful_payments,
        SUM(CASE WHEN is_failed THEN 1 ELSE 0 END) AS failed_payments,
        SUM(CASE WHEN is_successful THEN amount ELSE 0 END) AS daily_revenue,
        SUM(CASE WHEN is_failed THEN amount ELSE 0 END) AS failed_revenue
    FROM {{ ref('stg_payments') }}
    GROUP BY payment_date_only
),

active_subscriptions AS (
    SELECT
        d.date,
        COUNT(DISTINCT s.subscription_id) AS active_subscriptions,
        SUM(s.monthly_value) AS mrr
    FROM date_spine d
    LEFT JOIN {{ ref('stg_subscriptions') }} s
        ON d.date >= s.start_date
        AND (s.end_date IS NULL OR d.date <= s.end_date)
        AND s.is_active
    GROUP BY d.date
),

rolling_metrics AS (
    SELECT
        date,
        daily_active_users,
        SUM(daily_active_users) OVER (
            ORDER BY date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS weekly_active_users,
        SUM(daily_active_users) OVER (
            ORDER BY date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS monthly_active_users
    FROM daily_users
),

final AS (
    SELECT
        d.date,
        TO_CHAR(d.date, 'YYYYMMDD')::INTEGER AS date_key,
        
        -- User metrics
        COALESCE(u.daily_active_users, 0) AS daily_active_users,
        COALESCE(rm.weekly_active_users, 0) AS weekly_active_users,
        COALESCE(rm.monthly_active_users, 0) AS monthly_active_users,
        COALESCE(sig.new_signups, 0) AS new_signups,
        COALESCE(sig.activated_users, 0) AS activated_users,
        
        -- Engagement metrics
        COALESCE(s.total_sessions, 0) AS total_sessions,
        COALESCE(s.total_session_minutes, 0) AS total_session_minutes,
        COALESCE(s.avg_session_duration, 0) AS avg_session_duration,
        COALESCE(s.engaged_sessions, 0) AS engaged_sessions,
        COALESCE(e.total_events, 0) AS total_events,
        COALESCE(e.total_engagement_score, 0) AS total_engagement_score,
        
        -- Subscription metrics
        COALESCE(sub.new_subscriptions, 0) AS new_subscriptions,
        COALESCE(sub.new_trials, 0) AS new_trials,
        COALESCE(sub.new_paid_subscriptions, 0) AS new_paid_subscriptions,
        COALESCE(ch.churned_subscriptions, 0) AS churned_subscriptions,
        COALESCE(asub.active_subscriptions, 0) AS active_subscriptions,
        
        -- Revenue metrics
        COALESCE(p.total_payments, 0) AS total_payments,
        COALESCE(p.successful_payments, 0) AS successful_payments,
        COALESCE(p.failed_payments, 0) AS failed_payments,
        COALESCE(p.daily_revenue, 0) AS daily_revenue,
        COALESCE(asub.mrr, 0) AS mrr,
        COALESCE(asub.mrr, 0) * 12 AS arr,
        
        -- Calculated metrics
        CASE 
            WHEN COALESCE(sig.new_signups, 0) > 0 
            THEN COALESCE(sig.activated_users, 0)::FLOAT / sig.new_signups 
            ELSE 0 
        END AS activation_rate,
        
        CASE 
            WHEN COALESCE(p.total_payments, 0) > 0 
            THEN COALESCE(p.failed_payments, 0)::FLOAT / p.total_payments 
            ELSE 0 
        END AS payment_failure_rate,
        
        CASE 
            WHEN COALESCE(asub.active_subscriptions, 0) > 0 
            THEN COALESCE(asub.mrr, 0) / asub.active_subscriptions 
            ELSE 0 
        END AS arpu,
        
        CURRENT_TIMESTAMP AS dbt_updated_at
        
    FROM date_spine d
    LEFT JOIN daily_users u ON d.date = u.date
    LEFT JOIN rolling_metrics rm ON d.date = rm.date
    LEFT JOIN daily_signups sig ON d.date = sig.date
    LEFT JOIN daily_sessions s ON d.date = s.date
    LEFT JOIN daily_events e ON d.date = e.date
    LEFT JOIN daily_subscriptions sub ON d.date = sub.date
    LEFT JOIN daily_churn ch ON d.date = ch.date
    LEFT JOIN daily_payments p ON d.date = p.date
    LEFT JOIN active_subscriptions asub ON d.date = asub.date
    
    WHERE d.date <= CURRENT_DATE
)

SELECT * FROM final
ORDER BY date
