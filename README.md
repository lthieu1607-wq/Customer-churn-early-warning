# Customer Churn Early Warning

Predicting which fintech customers are about to leave, from changes in how they transact, and deciding who the retention team should contact first.

**[Open the live dashboards →](https://lthieu1607-wq.github.io/Customer-churn-early-warning/)**

## Dashboards

| Dashboard | What it answers |
|---|---|
| Executive Retention Overview | How big is churn, how much customer value is lost, and which segments matter most? |
| Early Warning Monitor | Which behaviors signal churn, and how well does the model separate churners? |
| Retention Action Center | Which customers to contact, why each was flagged, and what to do |
| Live Scoring | How the model scores a new customer once deployed, including the API response |

## Key results

- 48,723 customers, 21.1% churn. Customer value lost to churn: $366M (9.9% of total lifetime value).
- Demographics barely matter: churn sits between 18% and 25% for every segment, income bracket, age group and city.
- Three behaviors drive the model: shift in withdrawal share, change in average transaction amount, and days since the last transaction. Both amount and withdrawal changes are U-shaped: big moves in either direction raise churn.
- Random forest out-of-fold AUC: 0.745 with 62 features, 0.772 with only the 3 behavioral drivers.
- The High-risk tier (18% of customers) churns at 48%, and the two High-risk segments contain 36% of the value actually lost.

## Repository

```
notebooks/  04_eda_subscription.ipynb        Part 1: EDA and statistics on the subscription dataset
            05_early_warning_signals.ipynb   builds the churn label and Jan–Sep behavioral features
            06_churn_modeling.ipynb          logistic regression vs random forest, thresholds, ROC
            07_risk_scoring_retention.ipynb  out-of-fold risk scores, value at risk, priority segments
            08_tableau_data_prep.ipynb       warning signals and monthly activity for the dashboards
sql/        part1_subscription_churn.sql     PostgreSQL churn analysis (Part 1, subscription dataset)
reports/    intervention_strategy.md         retention playbook for each priority segment
docs/       index.html                       interactive dashboards (served by GitHub Pages)
            build_dashboard.py               aggregates the data, trains the 3-driver scoring model, writes index.html
            template.html                    dashboard layout and charts
data/       customer_data.csv                fintech customer profiles (raw)
            phase6_modeling_data.csv         modeling table: one row per customer, features + churn label
            phase7_risk_scores.csv           risk score, tier, value at risk, priority and action per customer
            phase8_tableau_customers.csv     dashboard extract, one row per customer
            phase8_tableau_monthly.csv       dashboard extract, monthly activity by outcome and risk tier
            customer_churn_2026.csv          subscription dataset used by the SQL and notebook 04
```

The project has two parts. **Part 1** (SQL and notebook 04) is an early exploration on a 5,000-customer subscription dataset. **Part 2** (notebooks 05–08 and the dashboards) is the main early-warning project on the fintech data.

`transactions_data.csv` (119 MB) is not included because it exceeds GitHub's file size limit. Place it in `data/` to run notebooks 05 and 08. Each later notebook loads the CSV saved by the one before it, so notebooks 06 and 07 run without it.

Run the notebooks from inside the `notebooks/` folder. Rebuild the dashboards after changing the data:

```bash
pip install pandas numpy scikit-learn matplotlib
python docs/build_dashboard.py data
```

## Notes

- Money is converted from Colombian pesos at the 2023 average rate of 4,325 COP per USD.
- The dataset has no revenue field, so customer lifetime value is used as the measure of value at risk.
- Churn is defined as no activity in Oct–Dec 2023; all model inputs use Jan–Sep behavior only.

*Coming next: Tableau Public dashboards and a reproducible pipeline.*
