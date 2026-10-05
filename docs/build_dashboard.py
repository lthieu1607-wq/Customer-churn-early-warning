"""Build dashboards/index.html from the Phase 8 Tableau extracts.

Reads phase8_tableau_customers.csv and phase8_tableau_monthly.csv, aggregates
everything the three dashboards need, trains the 3-driver random forest used
by the Live Scoring tab, and injects the results into template.html.

Usage:  python build_dashboard.py            (looks for the CSVs in ../data)
        python build_dashboard.py ~/Downloads
"""
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_predict

HERE = Path(__file__).resolve().parent
DATA_DIR = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else HERE.parent / "data"

c = pd.read_csv(DATA_DIR / "phase8_tableau_customers.csv")
m = pd.read_csv(DATA_DIR / "phase8_tableau_monthly.csv")


def churn_by(df, col, order=None):
    """[[label, customers, churn_rate], ...] for one grouping column."""
    g = df.groupby(col, observed=False)["churned"].agg(["size", "mean"])
    if order:
        g = g.reindex(order)
    return [[str(k), int(r["size"]), round(float(r["mean"]), 4)] for k, r in g.iterrows()]


def churn_by_bins(col, bins, labels):
    return churn_by(c.assign(_b=pd.cut(c[col], bins, labels=labels)), "_b")


D = {}

# ---- 24 Executive overview ----
D["kpi"] = dict(
    n=len(c),
    churned=int(c.churned.sum()),
    rate=round(c.churned.mean(), 4),
    lost=float(c.loc[c.churned, "customer_value"].sum()),
    total=float(c.customer_value.sum()),
    evar=float(c.expected_value_at_risk.sum()),
)
SIGNALS = ["Sharp drop in transaction amounts", "Sharp shift in withdrawal share",
           "Sharp surge in transaction amounts", "Inactive 14+ days", "No clear signal"]
D["signal"] = churn_by(c, "primary_warning_signal", SIGNALS)
D["segment"] = churn_by(c, "customer_segment", ["inactive", "occasional", "regular", "power"])
D["income"] = churn_by(c, "income_bracket", ["Low", "Medium", "High", "Very High"])

monthly = m.groupby(["month", "churned"])[["active_customers", "group_customers", "transactions"]].sum().reset_index()
D["monthly"] = {
    str(k): [[r.month[:7], round(r.active_customers / r.group_customers, 4), int(r.transactions)] for r in g.itertuples()]
    for k, g in monthly.groupby("churned")
}

lost_total = c.loc[c.churned, "customer_value"].sum()
evar_total = c.expected_value_at_risk.sum()
D["priority"] = [
    [seg, len(g), round(g.churned.mean(), 4),
     round(g.expected_value_at_risk.sum() / evar_total, 4),
     round(g.loc[g.churned, "customer_value"].sum() / lost_total, 4)]
    for seg, g in c.groupby("priority_segment")
]

# ---- 25 Early warning monitor ----
RISKS = ["High (> 0.30)", "Medium (0.20-0.30)", "Low (<0.20)"]
D["risk"] = churn_by(c, "risk_category", RISKS)

prob_bin = pd.cut(c.churn_probability, np.round(np.arange(0, 1.0001, 0.05), 2), include_lowest=True)
hist = c.groupby([prob_bin, "churned"], observed=False).size().unstack(fill_value=0)
D["hist"] = [[round(max(i.left, 0), 2), int(r[False]), int(r[True])] for i, r in hist.iterrows()]

D["amount"] = churn_by_bins("avg_amount_change_pct", [-1e9, -0.48, -0.35, -0.15, 0.15, 0.44, 1e9],
                            ["≤ −48%", "−48 to −35%", "−35 to −15%", "Stable ±15%", "+15 to +44%", "≥ +44%"])
D["withdraw"] = churn_by_bins("withdrawal_share_shift", [-9, -0.25, -0.15, -0.05, 0.05, 0.15, 0.25, 9],
                              ["≤ −25 pts", "−25 to −15", "−15 to −5", "Stable ±5", "+5 to +15", "+15 to +25", "≥ +25 pts"])
D["recency"] = churn_by_bins("days_since_last_tnx", [-1, 7, 14, 30, 60, 1e5], ["0–7 days", "8–14", "15–30", "31–60", "60+"])
D["logins"] = churn_by_bins("app_logins_frequency", [-1, 10, 20, 30, 40, 1e4], ["0–10", "11–20", "21–30", "31–40", "41+"])
D["failed"] = churn_by(c.assign(_f=c.failed_transactions.clip(upper=2).map({0: "0", 1: "1", 2: "2+"})), "_f", ["0", "1", "2+"])
D["tickets"] = churn_by(c.assign(_s=c.support_tickets_count.clip(upper=4).map(lambda v: "4+" if v == 4 else str(v))),
                        "_s", ["0", "1", "2", "3", "4+"])
D["satisf"] = churn_by(c.assign(_q=c.satisfaction_score.clip(3, 5).map({3: "≤ 3", 4: "4", 5: "5+"})), "_q", ["≤ 3", "4", "5+"])

# ---- 26 Action center: one row per customer, sorted by priority rank ----
segs = sorted(c.priority_segment.unique())
D["segs"] = segs
D["acts"] = [c.loc[c.priority_segment == s, "recommended_action"].iloc[0] for s in segs]
D["sigs"] = SIGNALS
D["risks"] = RISKS
ranked = c.sort_values("priority_rank")
D["rows"] = [[int(r.customer_id), round(r.churn_probability, 3), RISKS.index(r.risk_category),
              round(r.customer_value / 1e6, 1), SIGNALS.index(r.primary_warning_signal),
              segs.index(r.priority_segment), int(r.priority_rank)] for r in ranked.itertuples()]
D["drv"] = [[round(r.avg_amount_change_pct, 3), round(r.withdrawal_share_shift, 3), int(r.days_since_last_tnx)]
            for r in ranked.itertuples()]

# ---- Live scoring: 3-driver random forest, exported as a prediction grid ----
FEATURES = ["avg_amount_change_pct", "withdrawal_share_shift", "days_since_last_tnx"]
X, y = c[FEATURES].values, c.churned.values
rf = RandomForestClassifier(n_estimators=300, min_samples_leaf=50, random_state=42, n_jobs=-1)
oof = cross_val_predict(rf, X, y, cv=StratifiedKFold(5, shuffle=True, random_state=42), method="predict_proba")[:, 1]
print(f"3-driver model out-of-fold AUC: {roc_auc_score(y, oof):.3f}")
rf.fit(X, y)

A = np.round(np.arange(-1, 1.6001, 0.05), 2)   # amount change
W = np.round(np.arange(-0.6, 0.8001, 0.05), 2)  # withdrawal share shift
DAYS = np.arange(0, 121, 5)                     # days since last transaction
grid = np.array(np.meshgrid(A, W, DAYS, indexing="ij")).reshape(3, -1).T
p = rf.predict_proba(grid)[:, 1]
D["grid"] = dict(a=[A[0], 0.05, len(A)], w=[W[0], 0.05, len(W)], d=[0, 5, len(DAYS)],
                 p="".join(f"{min(999, int(round(v * 1000))):03d}" for v in p))
D["median_value"] = float(c.customer_value.median())

# ---- Write the page ----
body = (HERE / "template.html").read_text(encoding="utf-8")
body = body.replace("/*DATA*/null", json.dumps(D, ensure_ascii=False, separators=(",", ":")))
# Declare UTF-8 so the dashes, minus signs and ≤/≥ symbols display correctly
# when the file is opened locally or served from GitHub Pages.
head, body = body.split("</style>", 1)  # title, font links and styles go in <head>
page = (
    '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
    '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
    "<style>body{margin:0}[hidden]{display:none!important}</style>\n"
    + head + "</style>\n</head>\n<body>" + body + "\n</body>\n</html>\n"
)
(HERE / "index.html").write_text(page, encoding="utf-8")
print(f"Wrote {HERE / 'index.html'} ({len(page) / 1e6:.1f} MB)")
