"""
Loads the Understanding Society COVID-19 survey extract into Postgres.

Setup:
    pip install pandas sqlalchemy psycopg2-binary

Usage:
    python load_to_postgres.py

Note: raw data requires registration/download from the UK Data Service
(https://beta.ukdataservice.ac.uk/). Typically distributed as .tab or .dta
files — adjust the read function below (pd.read_csv / pd.read_stata) to match.
"""

import pandas as pd
from sqlalchemy import create_engine

# --- config -----------------------------------------------------------
RAW_XBASELINE_PATH = "../data/raw/xbaseline.tab"
RAW_XSAMPLE_PATH = "../data/raw/xsample.tab"
PG_CONN = "postgresql://postgres:postgres@localhost:5432/covid_household"

# --- load ---------------------------------------------------------------
xbaseline = pd.read_csv(RAW_XBASELINE_PATH, sep="\t")
xsample = pd.read_csv(RAW_XSAMPLE_PATH, sep="\t")

xbaseline.columns = xbaseline.columns.str.strip().str.lower()
xsample.columns = xsample.columns.str.strip().str.lower()

print(f"xbaseline: {len(xbaseline):,} rows")
print(f"xsample: {len(xsample):,} rows")

# --- load to postgres -----------------------------------------------------
engine = create_engine(PG_CONN)
xbaseline.to_sql("xbaseline", engine, if_exists="replace", index=False, chunksize=10000)
xsample.to_sql("xsample", engine, if_exists="replace", index=False, chunksize=10000)
print("Loaded xbaseline and xsample into Postgres")
