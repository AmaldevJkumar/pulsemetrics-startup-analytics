# PulseMetrics – Startup Analytics Platform

A complete analytics platform for SaaS startups, including synthetic data generation, data warehouse setup, dbt transformations, and business intelligence insights.

## 📋 Overview

PulseMetrics provides:
- **Synthetic Data Generation**: Realistic SaaS business data (users, sessions, events, subscriptions, payments)
- **Data Warehouse**: PostgreSQL schemas and tables optimized for analytics
- **dbt Transformations**: Staging models, dimension tables, fact tables, and metrics
- **Business Insights**: Pre-built reports and metric definitions

## 🏗️ Architecture

```
Data Generation (Python) → PostgreSQL (Raw Data) → dbt (Transformations) → Analytics Layer
```

## 📊 Metrics Included

- **User Metrics**: DAU, MAU, WAU, Activation Rate
- **Retention**: Cohort analysis, churn rate
- **Revenue**: MRR, ARR, LTV, ARPU
- **Product**: Feature adoption, session depth

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- PostgreSQL 12+
- pip (Python package manager)

### Step 1: Setup Python Environment

```bash
# Clone the repository
git clone <your-repo-url>
cd pulsemetrics

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
# source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Generate Synthetic Data

```bash
cd data_generation
python main.py
```

This generates 5 CSV files in `data_generation/output/`:
- `users.csv` (10,000 users)
- `sessions.csv` (100,000+ sessions)
- `events.csv` (500,000+ events)
- `subscriptions.csv` (3,000+ subscriptions)
- `payments.csv` (20,000+ payments)

### Step 3: Setup PostgreSQL Database

```bash
# Create database
psql -U postgres -c "CREATE DATABASE pulsemetrics;"

# Run setup scripts
psql -U postgres -d pulsemetrics -f warehouse/01_create_schemas.sql
psql -U postgres -d pulsemetrics -f warehouse/02_create_tables.sql

# Update file paths in 03_load_data.sql to match your system
# Then load data
psql -U postgres -d pulsemetrics -f warehouse/03_load_data.sql
```

### Step 4: Setup dbt

```bash
cd dbt/pulsemetrics_dbt

# Update profiles.yml with your PostgreSQL credentials

# Install dbt packages
dbt deps

# Test connection
dbt debug

# Run transformations
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 📁 Project Structure

```
pulsemetrics/
├── data_generation/     # Python scripts to generate synthetic data
├── warehouse/           # SQL scripts for database setup
├── dbt/                # dbt project with models and tests
├── docs/               # Metric definitions and documentation
└── insights/           # Business reports and recommendations
```

## 🎯 Key Features

### Data Generation
- Realistic user behavior patterns
- Multiple acquisition channels (Organic, Paid, Referral, Content)
- Subscription lifecycle (trials, conversions, upgrades, cancellations)
- Payment processing with realistic failure rates
- Seasonal trends and growth patterns

### dbt Models

**Staging Layer**: Clean and standardize raw data
- `stg_users`, `stg_sessions`, `stg_events`, `stg_subscriptions`, `stg_payments`

**Dimension Tables**: Reference data
- `dim_users`: User attributes and segmentation
- `dim_date`: Date dimension with fiscal periods
- `dim_plan`: Subscription plans
- `dim_channel`: Acquisition channels

**Fact Tables**: Metrics and measurements
- `fct_events`: User interaction events
- `fct_sessions`: Session-level metrics
- `fct_subscriptions`: Subscription lifecycle
- `fct_payments`: Payment transactions
- `fct_daily_metrics`: Daily aggregated KPIs

### Data Quality
- dbt tests for data integrity (unique, not_null, relationships)
- Schema validation
- Referential integrity checks

## 📈 Sample Queries

### Daily Active Users
```sql
SELECT 
    date,
    daily_active_users,
    weekly_active_users,
    monthly_active_users
FROM analytics.fct_daily_metrics
ORDER BY date DESC
LIMIT 30;
```

### MRR Trend
```sql
SELECT 
    date_trunc('month', created_at) as month,
    SUM(monthly_value) as mrr
FROM analytics.fct_subscriptions
WHERE status = 'active'
GROUP BY month
ORDER BY month;
```

### Cohort Retention
```sql
SELECT 
    date_trunc('month', signup_date) as cohort_month,
    COUNT(DISTINCT user_id) as cohort_size,
    COUNT(DISTINCT CASE WHEN days_since_signup >= 30 THEN user_id END) as retained_30d
FROM analytics.dim_users
GROUP BY cohort_month
ORDER BY cohort_month;
```

## 📚 Documentation

- **Metric Definitions**: See `docs/metric_definitions.md`
- **CEO Weekly Report**: See `insights/CEO_weekly_report.md`
- **Product Recommendations**: See `insights/product_recommendations.md`
- **dbt Docs**: Run `dbt docs serve` for interactive documentation

## 🧪 Testing

```bash
# Run all dbt tests
cd dbt/pulsemetrics_dbt
dbt test

# Run specific test
dbt test --select stg_users

# Run tests for a model and its dependencies
dbt test --select fct_daily_metrics+
```

## 🔄 Refresh Data

To regenerate data with new patterns:

```bash
# Generate new data
cd data_generation
python main.py

# Truncate existing tables
psql -U postgres -d pulsemetrics -c "TRUNCATE raw.users, raw.sessions, raw.events, raw.subscriptions, raw.payments CASCADE;"

# Reload data
psql -U postgres -d pulsemetrics -f warehouse/03_load_data.sql

# Re-run dbt models
cd dbt/pulsemetrics_dbt
dbt run
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For questions or issues:
- Create an issue in the repository
- Check the documentation in `/docs`
- Review dbt documentation with `dbt docs serve`

## 🎉 Acknowledgments

Built with:
- Python & Faker for data generation
- PostgreSQL for data warehousing
- dbt for analytics engineering
- Modern analytics engineering best practices
