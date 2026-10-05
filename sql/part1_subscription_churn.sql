-- Part 1: Subscription churn analysis (PostgreSQL)
-- Table: customer_churn, loaded from data/customer_churn_2026.csv (5,000 customers)
-- Early SQL exploration on a subscription dataset; the main project (notebooks 05-08) uses fintech data.

-- What does the customer base / churn situation look like?

-- Overall churn rate vs. retention rate
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN churn = 'No' THEN 1 ELSE 0 END) AS retained_customers,
    TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS churn_rate_pct,
    TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'No' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS retention_rate_pct
FROM customer_churn; -- 5000 total, 1085 churned (21.7%), 3915 retained (78.3%)

-- churn_by_contract_type

SELECT
    contract_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_rate_pct
FROM customer_churn
GROUP BY contract_type
ORDER BY churn_rate_pct DESC;

-- churn_by_plan_tier

SELECT
    plan_tier ,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2), 'FM999990.00%')  AS churn_rate_pct
FROM customer_churn
GROUP BY plan_tier
ORDER BY churn_rate_pct DESC;

-- average tenure, monthly charges, and total charges by churn

SELECT
    churn,
    ROUND(AVG(tenure_months),2) AS average_tenure,
    ROUND(AVG(monthly_charges)::numeric,2) AS average_monthly_charges,
    ROUND(AVG(total_charges)::numeric, 2) AS average_total_charges
FROM customer_churn
GROUP BY churn
ORDER BY average_tenure DESC;

-- total_revenue_lost due_to churn

SELECT
    COUNT(customer_id) AS total_churned_customers,
    churn,
    ROUND(SUM(monthly_charges)::numeric,2) AS total_lost_revenue
FROM customer_churn cc
WHERE churn = 'Yes'
GROUP BY churn;
-- 21.7% customers churned -> 1,085 customers -> $22,047.20/monthly recurring revenue lost, $22,047.20 x 12 = $264,566.40/yearly.

-- churn_by_service_segment

SELECT
     cc.service_segment,
     COUNT(customer_id),
     SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
     TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS churn_segment_pct
FROM customer_churn cc
GROUP BY cc.service_segment
ORDER BY churn_segment_pct DESC;

-- churn_by_Signup Channel

SELECT
    signup_channel,
    COUNT(customer_id),
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS churn_signup_channel_pct
FROM customer_churn
GROUP BY signup_channel
ORDER BY churn_signup_channel_pct DESC;

-- Churn_by_Primary_device

SELECT
    primary_device,
    COUNT(customer_id),
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS churn_by_device_pct
FROM customer_churn
GROUP BY primary_device
ORDER BY churn_by_device_pct DESC;

-- churn_by_payment_method

SELECT payment_method,
        COUNT(customer_id),
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    TO_CHAR(
        ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS churn_by_payment_method_pct
FROM customer_churn cc
GROUP BY payment_method
ORDER BY churn_by_payment_method_pct DESC;

-- tenure associated_with_churn rate

SELECT
    CASE
        WHEN tenure_months BETWEEN 0 AND 6 THEN '0-6 months'
        WHEN tenure_months BETWEEN 7 AND 12 THEN '7-12 months'
        WHEN tenure_months BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure_months BETWEEN 25 AND 48 THEN '25-48 months'
        WHEN tenure_months >= 49 THEN '49+ months'
    END AS tenure_group,
    COUNT(customer_id) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    TO_CHAR(ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id),2), 'FM999990.00%') AS churn_by_tenure_pct
FROM customer_churn cc
GROUP BY tenure_group
ORDER BY churn_by_tenure_pct DESC;

-- family_plan

SELECT has_family_plan,
       COUNT(*) AS total_customers,
       SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_by_family_plan_pct
FROM customer_churn cc
GROUP BY has_family_plan
ORDER BY churn_by_family_plan_pct DESC;

-- auto_pay

SELECT cc.auto_pay ,
       COUNT(*) AS total_customers,
       SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS churn_by_auto_pay_pct
FROM customer_churn cc
GROUP BY cc.auto_pay
ORDER BY churn_by_auto_pay_pct DESC;

-- Satisfaction_level

SELECT
    CASE WHEN satisfaction_score < 5 THEN 'Low'
         WHEN satisfaction_score >= 5 AND satisfaction_score < 8 THEN 'Medium'
         WHEN satisfaction_score >= 8 THEN 'High'
    END AS satisfaction_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customer,
    ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/COUNT(*), 2) AS churn_by_satisfaction_level_pct
FROM customer_churn
GROUP BY satisfaction_group
ORDER BY churn_by_satisfaction_level_pct DESC;

-- Do high-risk characteristics overlap in the same customers?
-- Row-level detail: which customers meet all four risk conditions at once?

SELECT
    customer_id,
    satisfaction_score,
    tenure_months,
    contract_type,
    auto_pay,
    churn
FROM customer_churn
WHERE satisfaction_score < 5
  AND tenure_months BETWEEN 0 AND 6
  AND contract_type = 'Month-to-month'
  AND NOT auto_pay;

-- Aggregated version: what's the churn rate WITHIN that high-risk overlap segment?
-- (the row-level query above never answered this - it just listed matching customers)

SELECT
    COUNT(*) AS high_risk_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS high_risk_churned,
    ROUND(100.0*SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0), 2) AS high_risk_churn_rate_pct
FROM customer_churn
WHERE satisfaction_score < 5
  AND tenure_months BETWEEN 0 AND 6
  AND contract_type = 'Month-to-month'
  AND NOT auto_pay;
-- Only 2 customers in the whole dataset meet all four conditions at once (1 churned = 50%).
-- Stacking conditions with AND is extremely restrictive - each condition alone flags a much
-- larger at-risk group. A weighted risk score works better than requiring every factor to co-occur.


