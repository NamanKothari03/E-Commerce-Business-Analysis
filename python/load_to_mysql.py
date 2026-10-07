"""
load_to_mysql.py
Splits data/ecommerce_clean.csv into 4 tables and loads them into MySQL.
Run AFTER schema.sql.   Usage (from project root):  python python/load_to_mysql.py
"""
import pandas as pd
from sqlalchemy import create_engine, text

# ---- EDIT THESE ----
USER = "root"
PASSWORD = "#NK864tua"
HOST = "localhost"
PORT = 3306
DB = "ecommerce"
# --------------------

df = pd.read_csv("data/ecommerce_clean.csv", parse_dates=["Order_Date"])
df["Returned_Flag"] = df["Returned"].eq("Yes")
print("Clean rows:", len(df))

# --- customers: one row per customer (prefer a real city over 'Unknown')
customers = (df.sort_values("City", key=lambda s: s.eq("Unknown"))
               .drop_duplicates("Customer_ID")[["Customer_ID", "City", "State", "Region"]])
customers.columns = ["customer_id", "city", "state", "region"]

# --- products: one row per product
products = df.drop_duplicates("Product_ID")[["Product_ID", "Product_Name", "Category", "Sub_Category"]]
products.columns = ["product_id", "product_name", "category", "sub_category"]

# --- orders: one row per order line
orders = df[["Order_ID", "Order_Date", "Customer_ID", "Product_ID", "Quantity", "Sales",
             "Discount", "Cost", "Profit", "Shipping_Cost", "Delivery_Days", "Payment_Mode"]].copy()
orders.columns = ["order_id", "order_date", "customer_id", "product_id", "quantity", "sales",
                  "discount", "cost", "profit", "shipping_cost", "delivery_days", "payment_mode"]

engine = create_engine(f"mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB}")

with engine.begin() as conn:
    customers.to_sql("customers", conn, if_exists="append", index=False, chunksize=5000)
    products.to_sql("products", conn, if_exists="append", index=False, chunksize=5000)
    orders.to_sql("orders", conn, if_exists="append", index=False, chunksize=5000)

    # returns need the auto-generated order_line_id, so read the keys back
    keys = pd.read_sql(text("SELECT order_line_id FROM orders ORDER BY order_line_id"), conn)
    orders = orders.reset_index(drop=True)
    orders["order_line_id"] = keys["order_line_id"].values
    returns = pd.DataFrame({
        "order_line_id": orders.loc[df["Returned_Flag"].values, "order_line_id"],
        "returned_revenue": df.loc[df["Returned_Flag"], "Sales"].values,
    })
    returns.to_sql("returns", conn, if_exists="append", index=False, chunksize=5000)

with engine.connect() as conn:
    for t in ["customers", "products", "orders", "returns"]:
        n = conn.execute(text(f"SELECT COUNT(*) FROM {t}")).scalar()
        print(f"{t:10s} {n:>8,} rows")
