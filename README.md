# PulseMetrics – Startup Analytics Platform

A complete, production-ready analytics platform for SaaS startups, featuring synthetic data generation, data warehouse setup, and dbt-powered transformations.

## 🎯 Overview

PulseMetrics provides end-to-end analytics infrastructure for tracking and analyzing key SaaS metrics including:
- User acquisition and activation
- Session and event analytics
- Subscription lifecycle management
- Revenue metrics (MRR, ARR, LTV)
- Cohort analysis and retention tracking

## 📁 Project Structure

```
pulsemetrics/
├── data_generation/     # Python scripts to generate synthetic datasets
├── warehouse/          # PostgreSQL schema and data loading scripts
├── dbt/               # dbt transformations (staging + marts)
├── docs/              # Metric definitions and documentation
└── insights/          # Example reports and recommendations
```

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- PostgreSQL 12+
- dbt-core 1.5+ with dbt-postgres adapter

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd pulsemetrics
```

2. **Set up Python environment**
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

3. **Set up PostgreSQL database**
```bash
# Create database (run in psql or pgAdmin)
CREATE DATABASE pulsemetrics;
```

## 📊 Step-by-Step Execution

### Step 1: Generate Synthetic Data

```bash
cd data_generation
python main.py
```

This generates 5 CSV files in `data_generation/output/`:
- `users.csv` (10,000 users)
- `sessions.csv` (~50,000 sessions)
- `events.csv` (~200,000 events)
- `subscriptions.csv` (~3,000 subscriptions)
- `payments.csv` (~15,000 payments)

### Step 2: Set Up Data Warehouse

1. **Create schemas and tables**
```bash
# Connect to PostgreSQL
psql -U postgres -d pulsemetrics

# Run setup scripts
\i warehouse/01_setup_schemas.sql
\i warehouse/02_create_tables.sql
```

2. **Load data**
```bash
# Edit warehouse/03_load_data.sql to update file paths
# Replace C:/path/to/pulsemetrics with your actual path
# Then run:
\i warehouse/03_load_data.sql
```

### Step 3: Run dbt Transformations

1. **Configure dbt profile**

Edit `dbt/pulsemetrics_dbt/profiles.yml` with your PostgreSQL credentials:

```yaml
pulsemetrics_dbt:
  outputs:
    dev:
      type: postgres
      host: localhost
      user: postgres
      password: your_password
      port: 5432
      dbname: pulsemetrics
      schema: analytics
      threads: 4
  target: dev
```

2. **Run dbt**
```bash
cd dbt/pulsemetrics_dbt

# Install dependencies
dbt deps

# Test connection
dbt debug

# Run models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 📈 Key Outputs

### Dimension Tables (analytics schema)
- `dim_users` - User master dimension
- `dim_date` - Date dimension with fiscal periods
- `dim_plan` - Subscription plan dimension
- `dim_channel` - Marketing channel dimension

### Fact Tables (analytics schema)
- `fct_events` - All user events with enriched context
- `fct_sessions` - Session-level metrics
- `fct_subscriptions` - Subscription lifecycle events
- `fct_payments` - Payment transactions with status
- `fct_daily_metrics` - Daily aggregated KPIs

## 📚 Documentation

- **[Metric Definitions](docs/metric_definitions.md)** - Comprehensive definitions for all KPIs
- **[CEO Weekly Report](insights/CEO_weekly_report.md)** - Example executive summary
- **[Product Recommendations](insights/product_recommendations.md)** - Data-driven product insights

## 🧪 Data Quality Tests

dbt tests cover:
- Uniqueness constraints on primary keys
- Not-null checks on critical fields
- Referential integrity between facts and dimensions
- Business logic validation (e.g., MRR > 0)

## 🔧 Configuration

### Data Generation Parameters

Edit `data_generation/config.py` to customize:
- Number of users, sessions, events
- Date ranges
- Conversion rates
- Churn rates
- Revenue distributions

### dbt Configuration

Edit `dbt/pulsemetrics_dbt/dbt_project.yml` to:
- Change materialization strategies
- Configure custom schemas
- Adjust model tags and documentation

## 📊 Sample Queries

```sql
-- Daily Active Users (DAU)
SELECT date, dau FROM analytics.fct_daily_metrics
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date;

-- Monthly Recurring Revenue (MRR)
SELECT date, mrr FROM analytics.fct_daily_metrics
WHERE date = (SELECT MAX(date) FROM analytics.fct_daily_metrics);

-- User Activation Rate
SELECT 
    COUNT(DISTINCT CASE WHEN is_activated THEN user_id END)::FLOAT / 
    COUNT(DISTINCT user_id) AS activation_rate
FROM analytics.dim_users;

-- 30-Day Retention by Cohort
SELECT 
    cohort_month,
    retention_day_30
FROM analytics.dim_users
GROUP BY cohort_month, retention_day_30
ORDER BY cohort_month;
```

## 🚢 Deployment Checklist

- [ ] Update `.gitignore` to exclude sensitive files
- [ ] Remove or secure `profiles.yml` (contains credentials)
- [ ] Update `README.md` with actual repository URL
- [ ] Add environment variable support for credentials
- [ ] Set up CI/CD for dbt (GitHub Actions, dbt Cloud, etc.)
- [ ] Configure data freshness checks
- [ ] Set up monitoring and alerting
- [ ] Document backup and recovery procedures
- [ ] Add data retention policies
- [ ] Create runbook for common issues

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please read CONTRIBUTING.md for guidelines.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ for data-driven startups**
