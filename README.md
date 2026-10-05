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
docs/   index.html            interactive dashboards (served by GitHub Pages)
        build_dashboard.py    aggregates the data, trains the 3-driver scoring model, writes index.html
        template.html         dashboard layout and charts
data/   phase8_tableau_customers.csv   one row per customer: risk score, tier, value, warning signal, action
        phase8_tableau_monthly.csv     monthly activity by outcome and risk tier
```

Rebuild the dashboards after changing the data:

```bash
pip install pandas numpy scikit-learn
python docs/build_dashboard.py data
```

## Notes

- Money is converted from Colombian pesos at the 2023 average rate of 4,325 COP per USD.
- The dataset has no revenue field, so customer lifetime value is used as the measure of value at risk.
- Churn is defined as no activity in Oct–Dec 2023; all model inputs use Jan–Sep behavior only.

*More to come: notebooks, SQL scripts and Tableau dashboards.*
