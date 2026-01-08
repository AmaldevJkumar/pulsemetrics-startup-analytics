# PulseMetrics Setup Guide
## Complete Step-by-Step Instructions for Windows

This guide will walk you through setting up PulseMetrics from scratch on a Windows machine.

---

## Prerequisites

Before starting, ensure you have:
- Windows 10 or 11
- Administrator access
- Stable internet connection
- At least 2GB free disk space

---

## Step 1: Install Python

### 1.1 Download Python

1. Go to https://www.python.org/downloads/
2. Download Python 3.11 or 3.12 (recommended)
3. Run the installer

### 1.2 Important: During Installation

- ✅ **Check** "Add Python to PATH"
- ✅ **Check** "Install pip"
- Click "Install Now"

### 1.3 Verify Installation

Open Command Prompt (cmd) and run:

```bash
python --version
pip --version
```

You should see version numbers for both.

---

## Step 2: Install PostgreSQL

### 2.1 Download PostgreSQL

1. Go to https://www.postgresql.org/download/windows/
2. Download the installer (version 14 or 15 recommended)
3. Run the installer

### 2.2 Installation Settings

- **Installation Directory**: Default is fine
- **Components**: Install all (PostgreSQL Server, pgAdmin 4, Stack Builder, Command Line Tools)
- **Data Directory**: Default is fine
- **Password**: Create a strong password and **WRITE IT DOWN**
- **Port**: 5432 (default)
- **Locale**: Default

### 2.3 Verify Installation

1. Open pgAdmin 4 from Start Menu
2. Enter your password
3. You should see PostgreSQL server listed

---

## Step 3: Clone or Download Project

### Option A: Using Git

```bash
# If you have Git installed
git clone https://github.com/YOUR_USERNAME/pulsemetrics-analytics.git
cd pulsemetrics-analytics
```

### Option B: Download ZIP

1. Download the project ZIP file
2. Extract to `C:\Users\YourName\pulsemetrics`
3. Open Command Prompt
4. Navigate to folder: `cd C:\Users\YourName\pulsemetrics`

---

## Step 4: Setup Python Environment

### 4.1 Create Virtual Environment

In the pulsemetrics folder:

```bash
python -m venv venv
```

### 4.2 Activate Virtual Environment

```bash
venv\Scripts\activate
```

You should see `(venv)` at the start of your command prompt.

### 4.3 Install Dependencies

```bash
pip install -r requirements.txt
```

This will take 2-3 minutes. You should see packages installing.

### 4.4 Verify Installation

```bash
pip list
```

You should see packages like: faker, pandas, numpy, dbt-core, dbt-postgres, psycopg2-binary

---

## Step 5: Generate Synthetic Data

### 5.1 Navigate to Data Generation Folder

```bash
cd data_generation
```

### 5.2 Run Data Generator

```bash
python main.py
```

**Expected Output:**
```
===========================================================
  PulseMetrics – Synthetic Data Generation
===========================================================

[1/5] Generating 10,000 users...
✓ Generated 10,000 users → output/users.csv

[2/5] Generating sessions...
✓ Generated 112,847 sessions → output/sessions.csv

[3/5] Generating events...
✓ Generated 534,219 events → output/events.csv

[4/5] Generating subscriptions...
✓ Generated 3,247 subscriptions → output/subscriptions.csv

[5/5] Generating payments...
✓ Generated 21,384 payments → output/payments.csv

===========================================================
  Summary
===========================================================
  Users:          10,000
  Sessions:       112,847
  Events:         534,219
  Subscriptions:  3,247
  Payments:       21,384

  Time elapsed:   14.32 seconds
  Output dir:     C:\Users\YourName\pulsemetrics\data_generation\output
===========================================================

✓ Data generation complete!
```

### 5.3 Verify CSV Files

Navigate to `data_generation\output\` and verify 5 CSV files exist.

### 5.4 Return to Project Root

```bash
cd ..
```

---

## Step 6: Setup PostgreSQL Database

### 6.1 Create Database

Open Command Prompt and run:

```bash
psql -U postgres -c "CREATE DATABASE pulsemetrics;"
```

Enter your PostgreSQL password when prompted.

**Alternative**: Use pgAdmin 4:
1. Open pgAdmin 4
2. Right-click "Databases"
3. Select "Create" > "Database"
4. Name: `pulsemetrics`
5. Click "Save"

### 6.2 Create Schemas

```bash
psql -U postgres -d pulsemetrics -f warehouse\01_create_schemas.sql
```

**Expected Output:**
```
CREATE SCHEMA
CREATE SCHEMA
SET
...
✓ Schemas created successfully: raw, analytics
```

### 6.3 Create Tables

```bash
psql -U postgres -d pulsemetrics -f warehouse\02_create_tables.sql
```

**Expected Output:**
```
DROP TABLE
DROP TABLE
...
CREATE TABLE
CREATE INDEX
...
✓ Tables created successfully in raw schema
```

### 6.4 Update Load Data Script

**IMPORTANT**: Before loading data, update file paths in `warehouse\03_load_data.sql`

1. Open `warehouse\03_load_data.sql` in a text editor
2. Find lines that say `FROM 'C:/path/to/your/pulsemetrics/...'`
3. Replace with your actual path, for example:
   ```
   FROM 'C:/Users/YourName/pulsemetrics/data_generation/output/users.csv'
   ```
4. Update ALL 5 file paths (users, sessions, events, subscriptions, payments)
5. **Use forward slashes** (/) not backslashes (\)
6. Save the file

### 6.5 Load Data

```bash
psql -U postgres -d pulsemetrics -f warehouse\03_load_data.sql
```

**Expected Output:**
```
Loading users...
COPY 10000

Loading sessions...
COPY 112847

Loading events...
COPY 534219

Loading subscriptions...
COPY 3247

Loading payments...
COPY 21384

✓ Data load complete! Verification:

 table_name    | row_count
---------------+-----------
 events        |    534219
 payments      |     21384
 sessions      |    112847
 subscriptions |      3247
 users         |     10000
```

### 6.6 Verify Data Loaded

```bash
psql -U postgres -d pulsemetrics -c "SELECT COUNT(*) FROM raw.users;"
```

Should return: 10000

---

## Step 7: Setup dbt

### 7.1 Navigate to dbt Project

```bash
cd dbt\pulsemetrics_dbt
```

### 7.2 Update profiles.yml

1. Open `profiles.yml` in a text editor
2. Find the line `password: your_password_here`
3. Replace with your PostgreSQL password
4. Save the file

**Example:**
```yaml
dev:
  type: postgres
  host: localhost
  user: postgres
  password: MySecurePassword123  # <-- Your actual password
  port: 5432
  dbname: pulsemetrics
  schema: analytics
  threads: 4
```

### 7.3 Install dbt Packages

```bash
dbt deps
```

**Expected Output:**
```
Installing dbt-labs/dbt_utils
  Installed from version 1.1.1
```

### 7.4 Test Connection

```bash
dbt debug
```

**Expected Output:**
```
...
Connection test: [OK connection ok]
All checks passed!
```

If you see errors, verify:
- PostgreSQL is running
- Password is correct in profiles.yml
- Database name is correct
- Port 5432 is accessible

---

## Step 8: Run dbt Transformations

### 8.1 Run All Models

```bash
dbt run
```

**Expected Output:**
```
Running with dbt=1.7.4
Found 15 models, 20 tests, 0 snapshots, ...

Concurrency: 4 threads

15:32:14  1 of 15 START sql view model staging.stg_users ................ [RUN]
15:32:14  1 of 15 OK created sql view model staging.stg_users ........... [OK in 0.23s]
15:32:14  2 of 15 START sql view model staging.stg_sessions ............. [RUN]
...
15:32:45  15 of 15 OK created sql table model analytics.fct_daily_metrics [OK in 2.34s]

Finished running 5 view models, 10 table models in 0 hours 0 minutes and 31.23 seconds.

Completed successfully

Done. PASS=15 WARN=0 ERROR=0 SKIP=0 TOTAL=15
```

### 8.2 Run Tests

```bash
dbt test
```

**Expected Output:**
```
Running with dbt=1.7.4
Found 15 models, 20 tests, ...

20:14:23  1 of 20 START test not_null_stg_users_user_id ................. [RUN]
20:14:23  1 of 20 PASS not_null_stg_users_user_id ....................... [PASS in 0.12s]
...
20:14:35  20 of 20 PASS unique_dim_users_user_id ........................ [PASS in 0.08s]

Finished running 20 tests in 0 hours 0 minutes and 12.34 seconds.

Completed successfully

Done. PASS=20 WARN=0 ERROR=0 SKIP=0 TOTAL=20
```

---

## Step 9: Explore Your Data

### 9.1 Generate Documentation

```bash
dbt docs generate
```

### 9.2 View Documentation

```bash
dbt docs serve
```

This will open a browser window with interactive documentation.

**Features**:
- Model lineage graphs
- Column descriptions
- SQL code
- Test results

### 9.3 Run Sample Queries

Open pgAdmin 4 or use psql:

**Daily Active Users:**
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

**MRR Trend:**
```sql
SELECT 
    date,
    mrr,
    arr,
    active_subscriptions
FROM analytics.fct_daily_metrics
WHERE date >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY date;
```

**User Segmentation:**
```sql
SELECT 
    engagement_segment,
    COUNT(*) as user_count,
    AVG(total_sessions) as avg_sessions,
    AVG(total_engagement_score) as avg_engagement
FROM analytics.dim_users
GROUP BY engagement_segment
ORDER BY avg_engagement DESC;
```

**Top Acquisition Channels:**
```sql
SELECT 
    acquisition_channel,
    COUNT(*) as users,
    SUM(CASE WHEN has_active_subscription THEN 1 ELSE 0 END) as paying_users,
    ROUND(100.0 * SUM(CASE WHEN has_active_subscription THEN 1 ELSE 0 END) / COUNT(*), 2) as conversion_rate
FROM analytics.dim_users
GROUP BY acquisition_channel
ORDER BY users DESC;
```

---

## Step 10: Review Business Insights

### 10.1 Read Metric Definitions

Open `docs\metric_definitions.md` to understand all metrics.

### 10.2 Review CEO Report

Open `insights\CEO_weekly_report.md` for executive summary.

### 10.3 Review Product Recommendations

Open `insights\product_recommendations.md` for data-driven insights.

---

## Troubleshooting

### Issue: "Python is not recognized"
**Solution**: 
1. Reinstall Python
2. Make sure to check "Add Python to PATH"
3. Restart Command Prompt

### Issue: "psql is not recognized"
**Solution**: 
1. Add PostgreSQL to PATH:
   - Search "Environment Variables" in Windows
   - Edit System Environment Variables
   - Add: `C:\Program Files\PostgreSQL\15\bin`
2. Restart Command Prompt

### Issue: "COPY command failed"
**Solution**:
1. Verify file paths in `03_load_data.sql` are correct
2. Use forward slashes (/) not backslashes (\)
3. Ensure CSV files exist
4. Check PostgreSQL has read permissions

### Issue: "dbt run fails"
**Solution**:
1. Verify PostgreSQL password in `profiles.yml`
2. Run `dbt debug` to identify issue
3. Check that raw data loaded successfully
4. Ensure schemas exist

### Issue: "Permission denied"
**Solution**:
1. Run Command Prompt as Administrator
2. Check file permissions
3. Verify antivirus isn't blocking

### Issue: "Port 5432 already in use"
**Solution**:
1. Another PostgreSQL instance is running
2. Change port in PostgreSQL config and profiles.yml
3. Or stop other PostgreSQL service

---

## Next Steps

### Explore the Data
- Run different queries
- Create visualizations
- Export data to CSV
- Connect BI tools (Tableau, Power BI, Metabase)

### Modify the Project
- Add new metrics to fct_daily_metrics
- Create custom dbt models
- Add more data generation parameters
- Build dashboards

### Learn More
- Study the dbt models to understand transformations
- Review SQL patterns used
- Explore dbt documentation: https://docs.getdbt.com
- Read analytics engineering best practices

---

## Useful Commands Reference

### Data Generation
```bash
cd data_generation
python main.py
```

### PostgreSQL
```bash
# Create database
psql -U postgres -c "CREATE DATABASE pulsemetrics;"

# Run SQL file
psql -U postgres -d pulsemetrics -f warehouse\01_create_schemas.sql

# Run query
psql -U postgres -d pulsemetrics -c "SELECT COUNT(*) FROM raw.users;"

# Open interactive shell
psql -U postgres -d pulsemetrics
```

### dbt
```bash
cd dbt\pulsemetrics_dbt

# Install packages
dbt deps

# Test connection
dbt debug

# Run models
dbt run

# Run specific model
dbt run --select dim_users

# Run tests
dbt test

# Generate docs
dbt docs generate

# Serve docs
dbt docs serve

# Clean artifacts
dbt clean
```

### Python Virtual Environment
```bash
# Create
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Deactivate
deactivate
```

---

## Support

If you need help:
1. Check the troubleshooting section above
2. Review README.md
3. Check dbt documentation
4. Review SQL error messages carefully
5. Google the specific error message
6. Create an issue on GitHub

---

## Success Checklist

You've successfully completed setup when:

- ✅ Python environment activated
- ✅ All CSV files generated (5 files)
- ✅ PostgreSQL database created
- ✅ Raw data loaded (5 tables with data)
- ✅ dbt models run successfully (15 models)
- ✅ All tests pass (20 tests)
- ✅ Documentation generated and viewable
- ✅ Sample queries return results

**Congratulations! You now have a fully functional analytics platform! 🎉**

---

## Time Estimate

- Python & PostgreSQL Installation: 30 minutes
- Project Setup: 15 minutes
- Data Generation: 5 minutes
- Database Setup: 15 minutes
- dbt Setup & Execution: 20 minutes

**Total**: ~1.5 hours for first-time setup

---

*For questions or issues, refer to README.md or create a GitHub issue.*
