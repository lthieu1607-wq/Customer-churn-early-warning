# Customer Retention Intervention Strategy

**Project:** Customer Retention & Early-Warning Churn Analytics, Phase 7
**Input:** `phase7_risk_scores.csv` (48,723 customers scored by a Random Forest churn model, out-of-fold AUC 0.745)

---

## 1. Purpose

Every customer now has a churn probability, a risk tier and a lifetime value. This document sets out **what the business should do for each group of customers**, so that retention effort and budget go where they protect the most value.

Customers are grouped into four segments by combining **churn risk** with **customer value**:

| Segment | Customers | Share | Actual churn rate | Median lifetime value | Share of value lost to churn* |
|---|---|---|---|---|---|
| **1. High Risk + High Value** | 3,657 | 7.5% | 42.6% | $53.9K | 26.6% |
| **2. High Risk + Low Value** | 5,229 | 10.7% | 51.7% | $12.8K | 9.6% |
| **3. Medium Risk** | 13,782 | 28.3% | 24.1% | $23.6K | 30.7% |
| **4. Low Risk** | 26,055 | 53.5% | 10.3% | $38.2K | 33.0% |

\*Share of total lifetime value belonging to customers who actually churned in the outcome window.
Values are converted from Colombian pesos at the 2023 average rate of 4,325 COP per USD.

**What drives churn:** permutation importance identifies three real behavioral drivers:

| Signal | Stable customers | Warning pattern | Churn rate in warning group |
|---|---|---|---|
| Change in average transaction amount | 12–14% churn | Sharp **drop** (≤ −35%) | 38% |
| | | Sharp **surge** (≥ +44%) | 29% |
| Shift in withdrawal share | 7–11% churn | Large shift in **either direction** (≤ −0.15 or ≥ +0.25) | 33% |
| Days since last transaction | 12% churn (active in the last day) | No transaction for 14+ days | 23% |

**Sharp swings in either direction** signal churn, not just declines. App logins, failed transactions, support tickets and satisfaction scores show no relationship with churn in this data (churn is flat at ~21% across all their levels). Demographics contribute very little.

---

## 2. Strategy by Segment

### Segment 1 — High Risk + High Value → Personalized customer-success outreach

**Who:** 3,657 customers (7.5%). Nearly half churn without action, and each is worth about 4× a Segment 2 customer. Together they account for ~27% of the value lost to churn.

**Action**
- Assign each customer to a customer-success manager, working in `priority_rank` order (highest expected value at risk first).
- Reach them personally by phone or a direct message from a named contact, within 7 days of being flagged.
- Before contacting, review the customer's **primary warning signal** and tailor the conversation to it:
  - *Transaction amounts dropped sharply:* review whether their products still fit their needs; offer a fee review or a better-suited product.
  - *Transaction amounts surged sharply:* check whether they are moving large sums (for example, preparing to transfer funds elsewhere); present savings or investment options to keep funds on the platform.
  - *Withdrawal pattern shifted sharply:* ask about changes in their financial needs; make sure the service still matches how they use it.
  - *Inactive for 14+ days:* check for service problems; remind them of features relevant to how they used the account.
- Offer retention incentives (fee waivers, better rates) on a case-by-case basis. Keep the cost well below the customer's expected value at risk.

**Why it is worth the cost:** this is the smallest group but the most expensive to lose. Personal outreach does not scale to thousands of customers, but it is affordable for 3,657.

**Caution:** the model overestimates churn risk for the very highest-value customers (12% predicted vs 5% actual in the top value decile). For the top-ranked customers, confirm that a real warning signal is present before making a costly offer.

---

### Segment 2 — High Risk + Low Value → Automated retention campaign

**Who:** 5,229 customers (10.7%). This segment has the **highest churn rate (52%)** but the lowest value per customer (median $12.8K).

**Action**
- Enroll customers automatically in a retention journey of email, push and in-app messages over about 4 weeks.
- Tailor the message to the warning signal (reminders of unused features, simple savings nudges, a "we miss you" message after inactivity).
- Use small, low-cost incentives only, such as a one-month fee waiver or cashback on the next transaction.

**Why automated:** many customers are likely to leave, but each is worth relatively little, so the cost per contact must stay low. Automation reaches all of them at almost no marginal cost.

---

### Segment 3 — Medium Risk → Targeted engagement campaign

**Who:** 13,782 customers (28.3%) with about-average churn (24%). The group accounts for ~31% of value lost, mainly because it is large.

**Action**
- Run engagement campaigns that encourage **steady, regular transactions**, the behavior of the lowest-churn customers, and adoption of products such as savings and auto-saving.
- Prioritize customers close to the High-risk threshold (probability 0.25–0.30), because they are the most likely to move into Segment 1 or 2.
- No financial incentives by default. The goal is to reinforce habits, not to buy loyalty.

**Why:** keeping these customers from sliding into High risk is cheaper than winning them back later.

---

### Segment 4 — Low Risk → Continue monitoring

**Who:** 26,055 customers (53.5%), with a churn rate of 10%.

**Action**
- No active retention spend.
- Keep them in normal marketing and service communications.
- Rescore them every month. Customers who move into Medium or High risk are routed automatically to the matching campaign.
- Flag **very high-value customers** in this segment for account-management awareness only. They carry large lifetime value, but their actual churn is very low.

**Why:** spending on customers who are already likely to stay gives little return.

---

## 3. Summary of Actions

| Segment | Action | Channel | Incentive level | Owner | Timing |
|---|---|---|---|---|---|
| 1. High Risk + High Value | Personalized outreach | Phone / named contact | Case-by-case | Customer Success | Within 7 days of flag |
| 2. High Risk + Low Value | Automated retention journey | Email, push, in-app | Small, standard | Marketing Automation | Starts on flag, ~4 weeks |
| 3. Medium Risk | Targeted engagement | Email, in-app | None by default | Marketing | Monthly |
| 4. Low Risk | Monitor | — | None | Analytics | Monthly rescoring |

---

## 4. Measuring Success

The model shows **who is at risk**, not **whether an intervention will work**. Association is not causation. Each campaign should be tested before it is scaled.

- **Control groups:** within each segment, randomly hold out about 10% of customers who receive no intervention. Comparing their churn with the treated group shows the real effect of the campaign.
- **Key metrics per segment:**
  - Churn rate, treated vs control, over the next 90 days
  - Lifetime value retained vs cost of the intervention
  - Change in warning signals (transaction amount change, withdrawal share shift, days since last transaction)
  - Movement between risk tiers at each monthly rescore
- **Review cycle:** review results monthly; adjust thresholds, messages and incentives based on what actually reduces churn.

---

## 5. Limitations

- **Coverage:** at the 0.30 threshold, the model identifies about 41% of churners. The rest leave without clear warning signals in the current data, so this strategy cannot reach them.
- **High-value overestimation:** churn risk is overstated for the most valuable customers, which inflates their expected value at risk.
- **Customer value is an estimate.** Lifetime value is a projection, not realized revenue.
- **Few real signals.** Only three behavioral features carry predictive power. Service-experience data (support tickets, satisfaction, failed transactions) showed no link to churn, so problems in those areas cannot currently be detected.
- **No causal evidence yet.** The recommended actions are reasonable hypotheses. Their effect must be confirmed through the control-group tests described above.
