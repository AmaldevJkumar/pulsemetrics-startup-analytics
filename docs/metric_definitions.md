# PulseMetrics – Metric Definitions

This document provides comprehensive definitions for all key metrics tracked in the PulseMetrics analytics platform.

## Table of Contents
- [User Metrics](#user-metrics)
- [Engagement Metrics](#engagement-metrics)
- [Retention & Churn](#retention--churn)
- [Revenue Metrics](#revenue-metrics)
- [Product Metrics](#product-metrics)

---

## User Metrics

### DAU (Daily Active Users)
**Definition**: The number of unique users who perform at least one event on a given day.

**Formula**: 
```sql
COUNT(DISTINCT user_id) 
WHERE event_date = [specific_date]
```

**Business Context**: DAU is the primary indicator of daily product engagement. A healthy SaaS product shows steady or growing DAU over time.

**Target**: Grow DAU by 10% month-over-month.

---

### WAU (Weekly Active Users)
**Definition**: The number of unique users who perform at least one event within a 7-day rolling window.

**Formula**: 
```sql
COUNT(DISTINCT user_id) 
WHERE event_date BETWEEN [date - 6 days] AND [date]
```

**Business Context**: WAU smooths out daily volatility and provides a better view of sustained engagement.

---

### MAU (Monthly Active Users)
**Definition**: The number of unique users who perform at least one event within a 30-day rolling window.

**Formula**: 
```sql
COUNT(DISTINCT user_id) 
WHERE event_date BETWEEN [date - 29 days] AND [date]
```

**Business Context**: MAU is a key metric for board reporting and reflects the overall size of your active user base.

**Industry Benchmark**: SaaS companies typically aim for MAU growth of 15-20% YoY in early stages.

---

### Activation Rate
**Definition**: The percentage of new signups who complete the activation process (defined as key onboarding actions).

**Formula**: 
```sql
(Activated Users / Total Signups) * 100
```

**Activation Criteria**:
- Complete profile setup
- Perform at least 3 core actions
- Spend >10 minutes in product within first 7 days

**Business Context**: Activation is the critical first step in converting signups to engaged users. Low activation rates indicate onboarding friction.

**Target**: 45%+ activation rate.

**Improvement Levers**:
- Simplify onboarding flow
- Add product tours
- Implement email nurture campaigns
- Reduce time-to-value

---

## Engagement Metrics

### Sessions per User
**Definition**: Average number of sessions per active user in a given period.

**Formula**: 
```sql
Total Sessions / COUNT(DISTINCT user_id)
```

**Business Context**: Higher session frequency indicates stronger product engagement and habit formation.

---

### Average Session Duration
**Definition**: Mean length of user sessions in minutes.

**Formula**: 
```sql
AVG(session_end - session_start)
```

**Business Context**: Longer sessions generally indicate deeper engagement, but context matters (e.g., workflow tools vs. quick-reference tools).

**Target**: 8-12 minutes for SaaS tools.

---

### Engagement Score
**Definition**: Weighted score based on the value of user actions.

**Scoring System**:
- Page view: 1 point
- Button click: 2 points
- Form submit: 3 points
- Settings change: 4 points
- Feature used: 5 points
- File upload: 5 points
- Report generated: 7 points
- Invite sent: 8 points

**Business Context**: Differentiates between shallow and deep engagement. Users with higher scores are more likely to convert and retain.

---

## Retention & Churn

### Cohort Retention
**Definition**: The percentage of users from a specific signup cohort who remain active after N days/months.

**Formula**: 
```sql
(Active Users in Month N / Total Users in Cohort) * 100
```

**Analysis Approach**:
```
Cohort Month | Month 0 | Month 1 | Month 2 | Month 3
Jan 2024     |   100%  |   65%   |   52%   |   45%
Feb 2024     |   100%  |   68%   |   55%   |   48%
```

**Business Context**: Retention is the #1 predictor of long-term success. Strong retention indicates product-market fit.

**Targets**:
- Month 1: 60%+
- Month 3: 40%+
- Month 6: 30%+
- Month 12: 25%+

---

### Churn Rate
**Definition**: The percentage of customers who cancel or fail to renew in a given period.

**Formula**: 
```sql
(Churned Subscriptions / Total Active Subscriptions at Start) * 100
```

**Types**:
- **Customer Churn**: % of customers lost
- **Revenue Churn**: % of MRR lost (can be negative with expansion)

**Business Context**: Monthly churn of 5%+ is unsustainable for most SaaS businesses. Aim for <3% monthly churn.

**Industry Benchmarks**:
- SMB SaaS: 3-7% monthly
- Mid-market: 1-2% monthly
- Enterprise: <1% monthly

---

### Churn Reasons Analysis
Track and categorize why customers churn:
- Price sensitivity (30%)
- Missing features (25%)
- Poor onboarding (20%)
- Found alternative (15%)
- Other (10%)

---

## Revenue Metrics

### MRR (Monthly Recurring Revenue)
**Definition**: Predictable revenue expected each month from active subscriptions.

**Formula**: 
```sql
SUM(monthly_value) 
WHERE status = 'active'
```

**Components**:
- New MRR: From new customers
- Expansion MRR: From upgrades
- Contraction MRR: From downgrades
- Churned MRR: From cancellations

**Net MRR Movement**:
```
Net New MRR = New MRR + Expansion MRR - Contraction MRR - Churned MRR
```

**Business Context**: MRR is the heartbeat of a SaaS business. Track both absolute MRR and MRR growth rate.

**Target**: 15-20% month-over-month growth in early stages.

---

### ARR (Annual Recurring Revenue)
**Definition**: Annualized value of recurring revenue.

**Formula**: 
```sql
MRR * 12
```

**Business Context**: ARR is the primary metric for board meetings and fundraising discussions.

---

### ARPU (Average Revenue Per User)
**Definition**: Average monthly revenue per active customer.

**Formula**: 
```sql
Total MRR / Active Subscriptions
```

**Business Context**: ARPU helps identify monetization opportunities. Growing ARPU indicates successful upselling/pricing optimization.

**Improvement Levers**:
- Add premium features
- Introduce usage-based pricing
- Implement annual billing incentives
- Optimize pricing tiers

---

### LTV (Lifetime Value)
**Definition**: Total revenue expected from a customer over their entire relationship.

**Formula**: 
```sql
ARPU / Monthly Churn Rate
```

**Alternative Formula** (with gross margin):
```sql
(ARPU * Gross Margin) / Monthly Churn Rate
```

**Example**:
- ARPU: $79/month
- Churn: 3% monthly
- LTV: $79 / 0.03 = $2,633

**Business Context**: LTV must exceed CAC by at least 3x for a healthy business.

---

### CAC (Customer Acquisition Cost)
**Definition**: Average cost to acquire one paying customer.

**Formula**: 
```sql
Total Sales & Marketing Expenses / New Customers Acquired
```

**Business Context**: Track CAC by channel to optimize marketing spend.

**Channel CAC** (from our data):
- Organic: $0
- Referral: $50
- Content: $80
- Paid Social: $120
- Paid Search: $150

---

### LTV:CAC Ratio
**Definition**: The ratio of customer lifetime value to acquisition cost.

**Formula**: 
```sql
LTV / CAC
```

**Targets**:
- <1: Unsustainable
- 1-3: Acceptable but risky
- 3+: Healthy, scalable
- >5: Underinvesting in growth

---

### CAC Payback Period
**Definition**: Time required to recover customer acquisition costs.

**Formula**: 
```sql
CAC / (ARPU * Gross Margin)
```

**Business Context**: Shorter payback periods improve cash flow. Aim for <12 months.

---

### Payment Failure Rate
**Definition**: Percentage of payment attempts that fail.

**Formula**: 
```sql
(Failed Payments / Total Payment Attempts) * 100
```

**Business Context**: Failed payments lead to involuntary churn. Industry average is 6-8%.

**Reduction Strategies**:
- Update card on file campaigns
- Smart retry logic
- Alternative payment methods
- Dunning management

---

## Product Metrics

### Feature Adoption Rate
**Definition**: Percentage of users who have used a specific feature.

**Formula**: 
```sql
(Users Who Used Feature / Total Active Users) * 100
```

**Business Context**: Identifies underutilized features that may need better discovery or education.

---

### Time to Value (TTV)
**Definition**: Time elapsed between signup and first meaningful value delivery.

**Measurement**: Days from signup to activation event.

**Business Context**: Faster TTV drives higher activation and retention. Best-in-class products deliver value in <5 minutes.

---

### Stickiness Ratio
**Definition**: Ratio of DAU to MAU, indicating how often users return.

**Formula**: 
```sql
(DAU / MAU) * 100
```

**Interpretation**:
- 20%+: Highly sticky (users return 6+ days/month)
- 10-20%: Moderately sticky
- <10%: Low stickiness, retention risk

**Business Context**: Social networks often have 50%+ stickiness. SaaS tools typically range from 15-30%.

---

## How to Use These Metrics

### Weekly Review
Focus on:
- DAU, WAU, MAU trends
- Activation rate
- MRR growth
- Payment failure rate

### Monthly Review
Deep dive into:
- Cohort retention analysis
- Churn reasons
- LTV:CAC by channel
- Feature adoption

### Quarterly Review
Strategic analysis:
- Long-term retention curves
- Unit economics (LTV, CAC, Payback)
- ARR growth and projections
- Competitive benchmarking

---

## Data Sources

All metrics are calculated from these core tables:
- `analytics.fct_daily_metrics`: Pre-aggregated KPIs
- `analytics.dim_users`: User attributes
- `analytics.fct_sessions`: Engagement data
- `analytics.fct_subscriptions`: Subscription lifecycle
- `analytics.fct_payments`: Revenue data

## Questions?

For questions about metric definitions or calculation methodology, contact the Analytics Engineering team or review the dbt documentation with `dbt docs serve`.
