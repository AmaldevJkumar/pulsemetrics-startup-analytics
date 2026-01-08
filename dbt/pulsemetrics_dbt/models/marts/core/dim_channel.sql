-- Acquisition channel dimension
-- Defines marketing channel attributes

WITH channels AS (
    SELECT
        'organic' AS channel_key,
        'Organic Search' AS channel_name,
        'SEO' AS channel_category,
        'Unpaid search engine traffic' AS description,
        0 AS typical_cac,
        1 AS channel_tier
    
    UNION ALL
    
    SELECT
        'paid_search' AS channel_key,
        'Paid Search' AS channel_name,
        'Paid' AS channel_category,
        'Google Ads, Bing Ads' AS description,
        150 AS typical_cac,
        2 AS channel_tier
    
    UNION ALL
    
    SELECT
        'paid_social' AS channel_key,
        'Paid Social' AS channel_name,
        'Paid' AS channel_category,
        'Facebook, LinkedIn, Twitter ads' AS description,
        120 AS typical_cac,
        2 AS channel_tier
    
    UNION ALL
    
    SELECT
        'referral' AS channel_key,
        'Referral' AS channel_name,
        'Organic' AS channel_category,
        'User referrals and partnerships' AS description,
        50 AS typical_cac,
        1 AS channel_tier
    
    UNION ALL
    
    SELECT
        'content' AS channel_key,
        'Content Marketing' AS channel_name,
        'Organic' AS channel_category,
        'Blog posts, whitepapers, webinars' AS description,
        80 AS typical_cac,
        1 AS channel_tier
),

enriched AS (
    SELECT
        *,
        CASE
            WHEN channel_category = 'Organic' THEN true
            ELSE false
        END AS is_organic,
        
        CASE
            WHEN channel_category = 'Paid' THEN true
            ELSE false
        END AS is_paid,
        
        CURRENT_TIMESTAMP AS dbt_updated_at
        
    FROM channels
)

SELECT * FROM enriched
