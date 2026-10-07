"""
Synthetic E-Commerce dataset generator (India, INR)
---------------------------------------------------
Produces data/ecommerce_raw.csv with ~120k order lines, 2024-2025.

Business patterns deliberately baked in (so your analysis has real findings):
  1. Discounts >= 30% wipe out margin, especially in Furniture & Laptops.
  2. Some categories/sub-categories look strong on revenue but lose money.
  3. Grocery has tiny order values, so shipping eats the margin.
  4. COD orders and Fashion have much higher return rates.
  5. Slow-delivery states (Bihar, Assam, Odisha, West Bengal) churn more.
  6. Order volume is skewed: ~20% of customers drive most revenue.
  7. Nov-Dec seasonal peak.
Dirty data injected: duplicates, nulls, negative values, inconsistent text.

Run:  python generate_dataset.py
"""
import os
import numpy as np
import pandas as pd

rng = np.random.default_rng(42)

N_ORDERS = 70_000
N_CUST = 12_000
START, END = pd.Timestamp("2024-01-01"), pd.Timestamp("2025-12-31")

# ---------------------------------------------------------------- geography
# state: (region, cities, demand weight, base delivery days)
GEO = {
    "Maharashtra":   ("West",      ["Mumbai", "Pune", "Nagpur"],          0.16, 2.5),
    "Delhi":         ("North",     ["New Delhi"],                          0.10, 2.0),
    "Karnataka":     ("South",     ["Bengaluru", "Mysuru"],                0.11, 2.5),
    "Tamil Nadu":    ("South",     ["Chennai", "Coimbatore"],              0.09, 3.0),
    "Telangana":     ("South",     ["Hyderabad"],                          0.07, 2.5),
    "Gujarat":       ("West",      ["Ahmedabad", "Surat"],                 0.08, 3.0),
    "Rajasthan":     ("North",     ["Jaipur", "Jodhpur", "Udaipur"],       0.07, 4.0),
    "Uttar Pradesh": ("North",     ["Lucknow", "Noida", "Kanpur"],         0.09, 3.5),
    "West Bengal":   ("East",      ["Kolkata", "Siliguri"],                0.06, 5.0),
    "Bihar":         ("East",      ["Patna", "Gaya"],                      0.03, 6.5),
    "Odisha":        ("East",      ["Bhubaneswar", "Cuttack"],             0.02, 6.0),
    "Assam":         ("Northeast", ["Guwahati"],                           0.02, 7.5),
    "Kerala":        ("South",     ["Kochi", "Thiruvananthapuram"],        0.04, 3.5),
    "Madhya Pradesh": ("Central",  ["Indore", "Bhopal"],                   0.04, 4.0),
}
states = list(GEO)
state_w = np.array([GEO[s][2] for s in states]); state_w /= state_w.sum()

# ---------------------------------------------------------------- products
# category -> sub_category -> (avg list price INR, cost as share of list price)
CATALOG = {
    "Electronics":      {"Phones": (15000, 0.86), "Laptops": (55000, 0.91),
                         "Headphones": (3000, 0.62), "Accessories": (800, 0.45)},
    "Fashion":          {"Men's Wear": (1500, 0.52), "Women's Wear": (1800, 0.52),
                         "Footwear": (2200, 0.58)},
    "Home & Furniture": {"Sofas": (25000, 0.83), "Tables": (12000, 0.81),
                         "Decor": (1200, 0.48)},
    "Beauty":           {"Skincare": (700, 0.38), "Makeup": (900, 0.40)},
    "Grocery":          {"Staples": (350, 0.80), "Snacks": (250, 0.72)},
}
CAT_POP = {"Electronics": 0.20, "Fashion": 0.30, "Home & Furniture": 0.12,
           "Beauty": 0.13, "Grocery": 0.25}

rows = []
for cat, subs in CATALOG.items():
    for sub, (price, cost_ratio) in subs.items():
        for i in range(25):
            p = round(price * rng.lognormal(0, 0.3), 2)
            rows.append({"Category": cat, "Sub_Category": sub,
                         "Product_Name": f"{sub} Model {i+1:02d}",
                         "List_Price": p,
                         "Unit_Cost": round(p * cost_ratio * rng.uniform(0.95, 1.05), 2)})
products = pd.DataFrame(rows)
products["Product_ID"] = [f"P{i+1:04d}" for i in range(len(products))]
cat_count = products.groupby("Category")["Product_ID"].transform("count")
prod_w = products["Category"].map(CAT_POP) / cat_count
prod_w = (prod_w / prod_w.sum()).to_numpy()

# discount distribution by category (levels are shares of list price)
DISC_LEVELS = np.array([0, .05, .10, .15, .20, .30, .40, .50])
DISC_PROBS = {
    "Electronics":      [.35, .15, .15, .12, .10, .07, .04, .02],
    "Fashion":          [.15, .10, .12, .13, .15, .15, .12, .08],
    "Home & Furniture": [.15, .08, .10, .12, .15, .18, .14, .08],
    "Beauty":           [.25, .15, .18, .15, .12, .08, .05, .02],
    "Grocery":          [.45, .20, .15, .10, .06, .02, .01, .01],
}
RETURN_BASE = {"Electronics": .06, "Fashion": .18, "Home & Furniture": .08,
               "Beauty": .05, "Grocery": .01}

# ---------------------------------------------------------------- customers
cust_state = rng.choice(states, size=N_CUST, p=state_w)
cust_city = np.array([rng.choice(GEO[s][1]) for s in cust_state])
cust_weight = rng.gamma(0.6, 1.0, N_CUST)            # skewed order frequency
cust_weight /= cust_weight.sum()
cust_first = START + pd.to_timedelta(rng.integers(0, 540, N_CUST), unit="D")
cust_cod_pref = rng.random(N_CUST) < 0.25
cust_return_prone = rng.random(N_CUST) < 0.10

# churn: slower states and return-prone customers churn more
state_days = np.array([GEO[s][3] for s in cust_state])
churn_prob = np.clip(0.12 + 0.05 * (state_days - 3) + 0.12 * cust_return_prone, 0.05, 0.75)
churned = rng.random(N_CUST) < churn_prob
cust_last = pd.Series(np.where(
    churned,
    cust_first + pd.to_timedelta(rng.integers(45, 300, N_CUST), unit="D"),
    END)).clip(upper=END).to_numpy()
cust_first = cust_first.to_numpy()

# ---------------------------------------------------------------- orders
month_w = {1: .9, 2: .9, 3: 1, 4: 1, 5: 1, 6: .95, 7: .95, 8: 1.05,
           9: 1.05, 10: 1.25, 11: 1.5, 12: 1.4}
days = pd.date_range(START, END)
dw = np.array(days.month.map(month_w), dtype=float); dw = dw / dw.sum()
dates = rng.choice(days.to_numpy(), size=N_ORDERS, p=dw)
cust_idx = rng.choice(N_CUST, size=N_ORDERS, p=cust_weight)

for _ in range(40):                                  # keep orders inside customer's active window
    bad = (dates < cust_first[cust_idx]) | (dates > cust_last[cust_idx])
    if not bad.any():
        break
    cust_idx[bad] = rng.choice(N_CUST, size=bad.sum(), p=cust_weight)
bad = (dates < cust_first[cust_idx]) | (dates > cust_last[cust_idx])
dates[bad] = cust_first[cust_idx[bad]]

pay_modes = np.array(["UPI", "Credit Card", "Debit Card", "COD", "Net Banking"])
pay_default = np.array([.40, .20, .15, .17, .08])
order_pay = np.array([
    "COD" if cust_cod_pref[c] and rng.random() < 0.7 else rng.choice(pay_modes, p=pay_default)
    for c in cust_idx])
order_days = np.clip(np.round(state_days[cust_idx] + rng.normal(0, 1.2, N_ORDERS)), 1, 15)

# ---------------------------------------------------------------- order lines
n_lines = rng.choice([1, 2, 3], size=N_ORDERS, p=[.70, .20, .10])
o = np.repeat(np.arange(N_ORDERS), n_lines)
L = len(o)
pidx = rng.choice(len(products), size=L, p=prod_w)
prod = products.iloc[pidx].reset_index(drop=True)

qty = rng.choice([1, 2, 3, 4, 5], size=L, p=[.60, .20, .10, .06, .04])
qty = np.where(prod["List_Price"].to_numpy() > 10_000, 1, qty)

disc = np.zeros(L)
for cat, probs in DISC_PROBS.items():
    m = (prod["Category"] == cat).to_numpy()
    disc[m] = rng.choice(DISC_LEVELS, size=m.sum(), p=probs)

list_total = prod["List_Price"].to_numpy() * qty
sales = np.round(list_total * (1 - disc), 2)
cost = np.round(prod["Unit_Cost"].to_numpy() * qty, 2)
delivery = order_days[o]
shipping = np.round((50 + 12 * delivery) * (1 + 0.2 * (qty - 1)) * rng.uniform(.9, 1.1, L), 2)
profit = np.round(sales - cost - shipping, 2)

ret_p = prod["Category"].map(RETURN_BASE).to_numpy()
ret_p = ret_p * np.where(order_pay[o] == "COD", 1.6, 1.0) * np.where(disc >= .3, 1.2, 1.0)
ret_p = ret_p * np.where(cust_return_prone[cust_idx[o]], 2.5, 1.0)
returned = rng.random(L) < np.clip(ret_p, 0, 0.9)

df = pd.DataFrame({
    "Order_ID": [f"ORD-{i+1:06d}" for i in o],
    "Order_Date": pd.to_datetime(dates[o]).strftime("%Y-%m-%d"),
    "Customer_ID": [f"C{c+1:05d}" for c in cust_idx[o]],
    "Product_ID": prod["Product_ID"],
    "Product_Name": prod["Product_Name"],
    "Category": prod["Category"],
    "Sub_Category": prod["Sub_Category"],
    "Quantity": qty,
    "Sales": sales,
    "Discount": disc,
    "Cost": cost,
    "Profit": profit,
    "Shipping_Cost": shipping,
    "Delivery_Days": delivery.astype(int),
    "Region": [GEO[cust_state[c]][0] for c in cust_idx[o]],
    "State": cust_state[cust_idx[o]],
    "City": cust_city[cust_idx[o]],
    "Payment_Mode": order_pay[o],
    "Returned": np.where(returned, "Yes", "No"),
})

# ---------------------------------------------------------------- inject dirty data
n = len(df)
def pick(frac):
    return rng.choice(n, size=int(n * frac), replace=False)

df.loc[pick(.005), "Discount"] = np.nan
df.loc[pick(.005), "City"] = np.nan
df.loc[pick(.003), "Payment_Mode"] = np.nan
df.loc[pick(.002), "Quantity"] = -df["Quantity"]
df.loc[pick(.001), "Sales"] = -df["Sales"].abs()
i = pick(.01);  df.loc[i, "Category"] = df.loc[i, "Category"].str.lower()
i = pick(.01);  df.loc[i, "Category"] = " " + df.loc[i, "Category"].str.upper() + " "
i = pick(.01);  df.loc[i, "State"] = df.loc[i, "State"].str.lower()
i = pick(.005); df.loc[i, "Returned"] = df.loc[i, "Returned"].map({"Yes": "Y", "No": "N"})
df = pd.concat([df, df.sample(frac=.01, random_state=1)], ignore_index=True)   # duplicates
df = df.sample(frac=1, random_state=7).reset_index(drop=True)

os.makedirs("data", exist_ok=True)
df.to_csv("data/ecommerce_raw.csv", index=False)
print(f"Saved data/ecommerce_raw.csv  |  rows: {len(df):,}  |  customers: {df.Customer_ID.nunique():,}")
