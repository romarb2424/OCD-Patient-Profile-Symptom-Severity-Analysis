# OCD Patient Profile & Symptom Severity Analysis

## Business problem
Summarize patient demographics, recorded obsession/compulsion categories, Y-BOCS component scores, diagnosis flags, and data quality using MySQL. This is descriptive analysis, not clinical advice or causal analysis.

## Tools
- MySQL 8.0+
- MySQL Workbench

## Run the project
1. Open `OCD_Patient_SQL_Analysis.sql` in MySQL Workbench.
2. Run the setup section to create/select `ocd_analysis` and create the target table if it does not exist.
3. Import the source CSV into the existing `ocd_patients` table using Table Data Import Wizard. Map columns carefully and review any import errors.
4. Execute the remaining sections in order.

## What this project demonstrates
- Aggregations, grouping, sorting, subqueries, percentage calculations
- Data-quality checks for duplicate IDs, missing values, and numeric ranges
- A reusable reporting `VIEW`
- A `RANK()` window function
- Documentation of data limitations

## Selected findings from the imported table
- Imported rows: 1,393; unique Patient IDs: 1,393
- Age range: 18–75; average age: 46.99
- Average Y-BOCS obsession component score: 20.15
- Average Y-BOCS compulsion component score: 19.72
- Most frequent recorded obsession type: Harm-related (307 records)
- Most frequent recorded compulsion type: Washing (308 records)
- Depression diagnosis flag = Yes: 717 records (51.47%)
- Anxiety diagnosis flag = Yes: 698 records (50.11%)

## Data limitation
The source was expected to contain 1,500 rows, while the imported table contains 1,393. The cause of this 107-row difference has not been confirmed. The imported table has unique Patient IDs, but that does not establish whether the source had repeated IDs or whether import errors caused records to be omitted. Check the Workbench import log before concluding why.

## Privacy and licensing
Do not upload the CSV unless its license and sharing terms permit redistribution. Never commit passwords or connection credentials.
