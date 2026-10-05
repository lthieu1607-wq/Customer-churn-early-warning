# Customer Churn Early Warning | Python + Machine Learning + SQL

## 📊 Live Interactive Dashboard

Explore the interactive dashboards and the live model scoring demo here:

🔗 **[View the Live Dashboards](https://lthieu1607-wq.github.io/Customer-churn-early-warning/)**

🤖 **[Try the Live ML Scoring](https://lthieu1607-wq.github.io/Customer-churn-early-warning/#live)**

## Project Overview

This project builds a customer churn early-warning system for a Colombian fintech company. It uses 12 months of customer and transaction data to answer business questions about who is likely to leave, what behavior signals it ahead of time, how much customer value is at risk, and which customers the retention team should contact first.

The objective is to demonstrate an end-to-end analytics and machine learning workflow: defining churn from raw transactions, engineering early-warning features, training and validating models, turning predictions into risk scores, and delivering the results as dashboards and a retention playbook that support business decisions.

## Key Results

- Analyzed 48,723 customers and 3.16 million transactions from 2023
- Measured a 21.1% churn rate and $366M of customer lifetime value lost to churn (9.9% of total)
- Found that demographics barely matter: churn stays between 18% and 25% for every segment, income bracket, age group and city
- Identified 3 behavioral warning signals that raise churn from 10% to as high as 50%
- Built a random forest that outperforms the logistic regression baseline (AUC 0.761 vs 0.574)
- Scored every customer into High, Medium and Low risk tiers: the High tier is 18% of customers and churns at 48%
- Prioritized customers by risk × value: the two High-risk segments hold 36% of all value lost
- Built four interactive dashboards, including a live scoring demo of the deployed model

## Business Questions

### Executive Summary
- How many customers churned, and what is the churn rate?
- How much customer value was lost to churn?
- How much value is still at risk?
- Does churn differ by customer segment, income, age or city?

### Early Warning Signals
- Which customer behaviors change before a customer leaves?
- Does a drop in transaction amounts signal churn? Does a surge?
- Does a shift in how much a customer withdraws signal churn?
- Do inactivity, failed payments, support tickets or satisfaction scores predict churn?

### Machine Learning
- Can churn be predicted from Jan–Sep behavior before it happens in Oct–Dec?
- Does a random forest outperform logistic regression?
- Which decision threshold best balances catching churners against false alarms?
- Which features does the model actually rely on?

### Risk Scoring & Prioritization
- What is each customer's churn probability?
- How do customers split into High, Medium and Low risk tiers?
- Which customers combine high risk with high value?
- How much expected value is at risk in each segment?

### Retention Strategy
- What action should each priority segment receive?
- Which customers should the retention team contact first, and why was each one flagged?

### Part 1: SQL Exploration (subscription dataset)
- How does churn vary by contract type, plan tier, tenure, payment method and auto-pay?
- How much recurring revenue was lost to churn?
- Do high-risk characteristics overlap in the same customers?

---

## Machine Learning & Python Skills Demonstrated

- ✅ Data cleaning and merging with pandas
- ✅ Defining a churn label from raw transaction activity
- ✅ Time-window feature engineering (Jan–Sep behavior vs Oct–Dec outcome)
- ✅ Data leakage checks
- ✅ Statistical testing (chi-square, Spearman correlation)
- ✅ Logistic Regression and Random Forest (scikit-learn)
- ✅ Train/test split and stratified 5-fold cross-validation
- ✅ Out-of-fold predictions for unbiased risk scores
- ✅ ROC AUC, ROC curves, confusion matrices, precision and recall
- ✅ Decision threshold tuning
- ✅ Feature importance analysis
- ✅ Risk tiering and value-at-risk prioritization

## SQL Skills Demonstrated

- ✅ SELECT
- ✅ WHERE
- ✅ GROUP BY
- ✅ ORDER BY
- ✅ Aggregate Functions (COUNT, SUM, AVG)
- ✅ CASE Statements (conditional aggregation and bucketing)
- ✅ Churn and retention rate calculations
- ✅ Formatting with ROUND and TO_CHAR
- ✅ NULLIF for safe division
- ✅ Business-Oriented SQL Analysis

---

## Tools & Technologies

- Python (pandas, NumPy, scikit-learn, SciPy, Matplotlib)
- Jupyter Notebook
- PostgreSQL
- DBeaver
- HTML / JavaScript dashboards hosted on GitHub Pages
- GitHub
- Visual Studio Code

---

## Dataset

Dataset Source:

**[COFINFAD: Colombian Fintech Financial Analytics Dataset](https://data.mendeley.com/datasets/mhb4zn3258/1)** by Luis Eduardo Muñoz Guerrero, Yony Fernando Ceballos and Luis David Trejos Rojas (Mendeley Data, 2025, DOI: [10.17632/mhb4zn3258.1](https://doi.org/10.17632/mhb4zn3258.1)), licensed under CC BY 4.0.

- `customer_data.csv`: 48,723 customers with demographics, products and engagement metrics
- `transactions_data.csv`: 3,159,157 transactions from January to December 2023 (not included in this repo because it exceeds GitHub's 100 MB limit; download it from the source above and place it in `data/`)

Part 1 uses a separate subscription churn dataset (`customer_churn_2026.csv`, 5,000 customers).

## Project Structure

```
Customer-churn-early-warning/
│
├── README.md
│
├── notebooks/
│   ├── 04_eda_subscription.ipynb
│   ├── 05_early_warning_signals.ipynb
│   ├── 06_churn_modeling.ipynb
│   ├── 07_risk_scoring_retention.ipynb
│   └── 08_dashboard_data_prep.ipynb
│
├── sql/
│   └── part1_subscription_churn.sql
│
├── reports/
│   └── intervention_strategy.md
│
├── docs/
│   ├── index.html
│   ├── template.html
│   └── build_dashboard.py
│
└── data/
    ├── customer_data.csv
    ├── phase6_modeling_data.csv
    ├── phase7_risk_scores.csv
    ├── phase8_dashboard_customers.csv
    ├── phase8_dashboard_monthly.csv
    └── customer_churn_2026.csv
```

## Dashboard Highlights

### Executive Retention Overview
- Total Customers, Churn Rate and Retention Rate
- Total Customer Value, Value Lost to Churn and Expected Value at Risk
- Churn by Warning Signal vs Customer Segment
- Monthly Active Share: Churned vs Retained
- Highest-Risk Priority Segments

### Early Warning Monitor
- Risk Tiers with Actual Churn Rates
- Churn Probability Distribution
- Feature Importance of the Top Drivers
- Churn by Transaction Amount Change, Withdrawal Shift and Inactivity
- Model Scorecard and Confusion Matrix

### Retention Action Center
- Customers per Recommended Action
- Searchable Customer Table: ID, Churn Probability, Risk Category, Value, Warning Signal, Action
- "Why This Customer" Panel Explaining Each Flag

### Live ML Scoring
- Score a Customer with Interactive Inputs
- Churn Probability Gauge, Risk Tier and Recommended Action
- What-If Chart Showing What Moves the Score
- Sample API Response from a Deployed Model

## Skills Demonstrated

- Machine Learning
- Predictive Analytics
- Feature Engineering
- Statistical Analysis
- SQL Analytics
- Customer Segmentation
- Churn and Retention Analysis
- Data Visualization
- Dashboard Design
- Business Recommendations

## Notes

- Money is converted from Colombian pesos at the 2023 average rate of 4,325 COP per USD.
- The dataset has no revenue field, so customer lifetime value is used as the measure of value at risk.
- Churn is defined as no activity in Oct–Dec 2023, and all model inputs use Jan–Sep behavior only.
- To rebuild the dashboards after changing the data, run `python docs/build_dashboard.py data`.

## Conclusion

This project demonstrates an end-to-end analytics and machine learning workflow, from exploring churn with SQL and engineering early-warning signals in Python to training, validating and scoring a churn model, and delivering the results as interactive dashboards and a retention playbook that support data-driven decisions.
