# Project 7: Maji Ndogo — Transparency in Tracking Water Funds (Power BI)

## Overview
The final and most advanced Power BI project in the Maji Ndogo series. 
This project builds a real-time project tracking dashboard for President 
Naledi to monitor the progress of water infrastructure improvements, 
track expenditure against budget, and analyse vendor performance.

The dashboard answers the President's key questions:
- What is the current progress status of the project?
- How much have we spent so far?
- Will the budget be enough to complete the project?
- Which vendors are delivering the best value?

Completed as part of the ALX Africa / ExploreAI Data Analytics programme.

## Tools Used
- Power BI Desktop
- Advanced DAX (complex CALCULATE, FILTER, ALL, RELATED functions)
- Power BI KPI visuals
- Power BI date slicers for time-based filtering
- Power BI map with completion status colour-coding
- Data from updated `project_progress` table with vendor and cost data

---

## Dashboard Pages

### Page 1 — Project Progress Overview
The main monitoring dashboard showing:
- **KPI: % Population with Basic Water Access** — 33.59%
- **KPI: People Helped So Far** — 11,000+
- **KPI: % Project Complete** — 0% (early stage)
- **KPI: Sources to Go** — 25,369 remaining
- **Progress map** — town-level completion map (teal = complete, grey = backlog)
- **Date slicer** — filter map by completion date range
- **Cost breakdown pie** — spending by improvement type
- **Aggregated improvements** — cost per improvement type bar chart

### Page 2 — Financial Tracking
Budget monitoring with:
- **KPI visual** — Cumulative cost ($131,915) vs Budget ($128.45K)
- **Time trend** — Cost over time vs budget line
- **Province selector** — filter all visuals by province
- **Vendor breakdown** — cost per vendor

### Page 3 — Vendor Analysis
Identified best-value vendors by analysing:
- Cost per improvement type per vendor
- Geographic coverage of each vendor
- Most expensive vendor (MBS605) works in rural Sokoto — justified
- Best value vendor (Entebbe RO Installers) — stays local, minimises travel

---

## Key DAX Measure

```dax
population_with_basic_access =
    CALCULATE(
        SUM('water_source'[number_of_people_served]),
        FILTER(
            ALL(water_source),
            OR(
                OR(
                    AND(
                        'water_source'[type_of_water_source] = "well",
                        RELATED(well_pollution[results]) = "Clean"
                    ),
                    'water_source'[type_of_water_source] = "tap_in_home"
                ),
                AND(
                    'water_source'[type_of_water_source] = "shared_tap",
                    'water_source'[Average_queue_time] < 30
                )
            )
        )
    )
```

This measure calculates only the population with **genuinely basic** water 
access by applying UN service level standards directly in DAX.

---

## Key Findings

| Metric | Value |
|--------|-------|
| Current basic water access | **33.59%** |
| People helped so far | **11,000+** |
| Total spent (Year 1) | **$131,915** |
| Budget target | **$128,450** |
| Budget variance | **-2.7% (over budget)** |
| Sources remaining | **25,369** |
| Best value vendor | **Entebbe RO Installers** |
| Most expensive area | **Rural Sokoto** (justified by terrain) |

---

## 📊 Visualizations

### Project Progress Dashboard — KPIs & Cost Breakdown
![Progress Dashboard](images/p4_progress_dashboard.png)

### Cumulative Cost vs Budget & Top Vendors
![Cost and Vendors](images/p4_cost_vendors.png)

### Improvements by Province & Average Cost per Type
![Improvements and Cost](images/p4_improvements_cost.png)

### Advanced DAX — population_with_basic_access Measure
![DAX Measure](images/p4_dax_measure.png)

---

## Skills Demonstrated
- Advanced DAX: CALCULATE, FILTER, ALL, RELATED, nested OR/AND logic
- KPI visual design and configuration
- Time-based analysis with date slicers
- Vendor performance analysis
- Budget vs actual expenditure tracking
- Map-based project progress visualisation
- Data-driven decision making for resource allocation

## Data Source
ExploreAI Academy — Maji Ndogo Water Services Database (fictional dataset)
