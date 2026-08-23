# UK COVID-19 Household Impact Analysis

## Project Overview
Analysis of UK household employment, income and wellbeing during the COVID-19 pandemic using the Understanding Society dataset (UK Data Service).

## Business Questions Answered
- How did COVID-19 impact UK household employment rates?
- Which demographics were financially hit hardest?
- What was the working from home adoption rate?
- How did benefits change during the pandemic?
- What was the relationship between NHS shielding and employment?

## Key Findings
- 52% of respondents were employed during the COVID baseline period
- Only 6.5% of workers were working from home full time
- 46.2% gender pay gap identified — males earning £3,739.86 vs females £2,013.14
- Household-level earnings gap far narrower: 14% (£5,955 male vs £5,132 female), suggesting dual-income offset
- 65% of benefit claimants saw their benefits decrease during COVID
- 64% of NHS shielding respondents were not working

## Data Quality Note

An earlier version of the gender pay gap query filtered on `blhhearn_amount_dv > 0` but averaged `blpay_amount_dv` without applying the same filter, which meant missing-value codes (-8/-9) and zero entries were pulled into the average. This was caught in code review and corrected using separate `FILTER (WHERE ... > 0)` clauses on each average, then re-verified against the raw data. The corrected figures above reflect that fix.

## Tools Used
- PostgreSQL — data storage and SQL analysis
- pgAdmin — query execution
- Power BI — interactive dashboard
- Python (Pandas) — data conversion and loading
- UK Data Service — data source

## Dashboard
![COVID-19 Household Analysis Dashboard 1](screenshots/dashboard-overview-1.png)
![COVID-19 Household Analysis Dashboard 2](screenshots/dashboard-overview-2.png)

## Files
- `sql_queries.sql` — all 8 SQL queries used in analysis
- `screenshots/` — Power BI dashboard images


## Dataset
Understanding Society COVID-19 Survey — UK Data Service
20,462 respondents | 2020-2021
