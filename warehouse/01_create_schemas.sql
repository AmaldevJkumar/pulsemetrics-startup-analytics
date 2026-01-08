-- Create schemas for PulseMetrics data warehouse
-- Run this first after creating the database

-- Raw data schema (landing zone for CSV imports)
CREATE SCHEMA IF NOT EXISTS raw;

-- Analytics schema (transformed data from dbt)
CREATE SCHEMA IF NOT EXISTS analytics;

-- Set search path
SET search_path TO raw, analytics, public;

-- Grant permissions (adjust as needed for your environment)
GRANT USAGE ON SCHEMA raw TO PUBLIC;
GRANT USAGE ON SCHEMA analytics TO PUBLIC;

-- Confirm schemas created
SELECT 
    schema_name,
    schema_owner
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'analytics')
ORDER BY schema_name;

-- Success message
\echo '✓ Schemas created successfully: raw, analytics'
