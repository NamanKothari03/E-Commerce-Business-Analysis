"""
export_for_powerbi.py - saves the RFM customer segments from MySQL to data/customer_segments.csv
Run from the project root:   python python/export_for_powerbi.py
"""
import os
import getpass
import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

PASSWORD = os.environ.get("MYSQL_PASSWORD")
if PASSWORD is None:
    PASSWORD = getpass.getpass("MySQL root password: ")

engine = create_engine(f"mysql+pymysql://root:{quote_plus(PASSWORD)}@localhost:3306/ecommerce")

seg = pd.read_sql("""
    SELECT customer_id, state, region, orders, ROUND(revenue, 2) AS revenue, ROUND(profit, 2) AS profit,
           first_order, last_order, recency_days, ROUND(avg_delivery_days, 1) AS avg_delivery_days,
           returned_lines, order_lines, r_score, f_score, m_score, segment,
           CASE WHEN recency_days > 90 THEN 'Churned' ELSE 'Active' END AS churn_status
    FROM rfm_segments
""", engine)
seg["segment"] = seg["segment"].str[2:]          # drop the "1 " sort prefix: "Champions", "Loyal", ...

seg.to_csv("data/customer_segments.csv", index=False)
print(seg.shape)
print(seg["segment"].value_counts())
