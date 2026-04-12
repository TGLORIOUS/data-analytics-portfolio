# Project 2: Maji Ndogo Water Crisis Analysis (SQL)

## Overview
A 4-part integrated SQL project analysing a fictional water crisis in Maji Ndogo, 
a country of 27 million people. Using a real-world-style database of 60,000+ rows, 
this project covers data cleaning, exploratory analysis, multi-table JOINs, 
corruption investigation, and action planning.

Completed as part of the ALX Africa / ExploreAI Data Analytics programme.

## Database Structure
The `md_water_services` database contains the following tables:
- `employee` — Field surveyors and staff
- `location` — Geographic data (province, town, location type)
- `water_source` — Types of water sources and people served
- `visits` — Survey visit records linking sources to locations
- `well_pollution` — Pollution test results for wells
- `water_quality` — Subjective quality scores per visit
- `auditor_report` — Independent audit results (imported CSV)

## 📊 Visualizations

### Water Source Distribution — Maji Ndogo
![Water Source Distribution](./images/water_source_distribution.png)

### Water Source Usage by Province
![Province Water Analysis](./images/province_water_analysis.png)

### Corruption Investigation Results
![Corruption Investigation](./images/corruption_investigation.png)

---

## Tools Used
- MySQL (primary SQL engine)
- SQL functions: CONCAT, LOWER, REPLACE, TRIM, LENGTH, ROUND, FLOOR
- SQL concepts: JOINs, CTEs, Views, Subqueries, Temporary Tables, CASE statements

---

## Part 1 — Data Cleaning & Exploration

### Data Cleaning Tasks
- Generated employee email addresses using `CONCAT`, `LOWER`, `REPLACE`
- Fixed trailing spaces in phone numbers using `TRIM()`
- Verified data integrity with `LENGTH()` checks

### Key Findings
| Insight | Value |
|---------|-------|
| Total population surveyed | ~27 million citizens |
| Water sources in rural areas | 60% |
| People sharing a single shared tap (avg) | 2,071 |
| Largest water source type by users | Shared tap (43%) |

### Water Source Distribution
| Source Type | % Population Served |
|-------------|-------------------|
| Shared Tap | 43% |
| Well | 18% |
| Tap in Home | 17% |
| Tap in Home (Broken) | 14% |
| River | 9% |

---

## Part 2 — Advanced Querying & Pivot Tables

### Combined Analysis View
Built a `combined_analysis_table` VIEW joining 4 tables to enable efficient 
province and town level analysis without performance issues.

### Key Findings
- **Sokoto province** has the highest proportion of people drinking river water — drilling teams should be deployed there first
- **Amanzi (Amina town)** — only 3% have working home taps despite 56% having taps installed → broken infrastructure
- **Akatsi Rural** — 59% rely on shared taps with long queue times

---

## Part 3 — Corruption Investigation

### Methodology
1. Imported independent `auditor_report` CSV (1,620 re-visited sites)
2. Compared auditor scores vs surveyor scores using multi-table JOINs
3. Built `Incorrect_records` VIEW for reusable analysis
4. Used CTEs (`error_count`, `suspect_list`) to identify outliers
5. Cross-referenced with witness statements from the `statements` column

### Results
- **94% accuracy** — 1,518 of 1,620 records matched the auditor (excellent result)
- **102 incorrect records** identified
- **4 corrupt employees** flagged with above-average mistakes AND bribery statements:

| Employee | Mistakes |
|----------|---------|
| Bello Azibo | 26 |
| Malachi Mavuso | 21 |
| Zuriel Matembo | 17 |
| Lalitha Kaburi | 7 |

- Confirmed: Only these 4 employees had statements mentioning "cash" — no false positives

---

## Part 4 — Action Plan & Project Progress

### Improvement Logic (CASE statements)
| Condition | Action |
|-----------|--------|
| River source | Drill well |
| Well — chemical contamination | Install RO filter |
| Well — biological contamination | Install UV and RO filter |
| Shared tap — queue ≥ 30 min | Install X taps nearby (X = queue_time ÷ 30) |
| Broken home tap | Diagnose local infrastructure |

### Output
- **25,398 improvement tasks** generated and inserted into `Project_progress` table
- Table tracks: Address, Source type, Improvement needed, Status (Backlog/In Progress/Complete), Date of completion

### Priority Areas
1. **Sokoto** — Dispatch drilling teams for river-dependent communities
2. **Amanzi (Amina)** — Fix broken infrastructure (high-impact, quick win)
3. **Shared taps** with long queues — Install additional taps

---

## Files
- `maji_ndogo_part1_analysis.sql` — Data cleaning and exploration queries
- `maji_ndogo_part2_querying.sql` — Advanced JOINs, CTEs, Views, corruption investigation, and action plan

## Data Source
ExploreAI Academy — Maji Ndogo Water Services Database (fictional dataset)
