-- ============================================================
-- MAJI NDOGO WATER CRISIS: PARTS 2, 3 & 4
-- Advanced SQL: JOINs, CTEs, Views, Corruption Investigation
-- ============================================================

-- ============================================================
-- PART 2: BUILDING THE COMBINED ANALYSIS TABLE
-- ============================================================

-- Create a VIEW combining all key tables
CREATE VIEW combined_analysis_table AS
SELECT
    water_source.type_of_water_source AS source_type,
    location.town_name,
    location.province_name,
    location.location_type,
    water_source.number_of_people_served AS people_served,
    visits.time_in_queue,
    well_pollution.results
FROM visits
LEFT JOIN well_pollution ON well_pollution.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1;

-- Province-level water source breakdown (pivot table)
WITH province_totals AS (
    SELECT
        province_name,
        SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT
    ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;

-- Town-level water source breakdown
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
    SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY ct.province_name, ct.town_name
ORDER BY ct.town_name;

-- Towns with highest broken tap ratio
SELECT
    province_name,
    town_name,
    ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100, 0) AS Pct_broken_taps
FROM town_aggregated_water_access
ORDER BY Pct_broken_taps DESC;

-- ============================================================
-- PART 3: CORRUPTION INVESTIGATION
-- ============================================================

-- Create auditor_report table
DROP TABLE IF EXISTS auditor_report;
CREATE TABLE auditor_report (
    location_id VARCHAR(32),
    type_of_water_source VARCHAR(64),
    true_water_source_score INT DEFAULT NULL,
    statements VARCHAR(255)
);

-- Create Incorrect_records VIEW
CREATE VIEW Incorrect_records AS (
    SELECT
        auditor_report.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS surveyor_score,
        auditor_report.statements AS statements
    FROM auditor_report
    JOIN visits ON auditor_report.location_id = visits.location_id
    JOIN water_quality AS wq ON visits.record_id = wq.record_id
    JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
    WHERE visits.visit_count = 1
    AND auditor_report.true_water_source_score != wq.subjective_quality_score
);

-- Find corrupt employees using CTEs
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT
        employee_name,
        number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);

-- Result: 4 corrupt employees identified
-- Zuriel Matembo: 17 mistakes
-- Malachi Mavuso: 21 mistakes
-- Lalitha Kaburi: 7 mistakes
-- Bello Azibo: 26 mistakes

-- Verify cash bribery statements
WITH error_count AS (
    SELECT employee_name, COUNT(employee_name) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT employee_name, number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT DISTINCT employee_name
FROM Incorrect_records
WHERE statements LIKE '%cash%'
AND employee_name NOT IN (SELECT employee_name FROM suspect_list);
-- Returns empty result - confirms only suspects involved in bribery

-- ============================================================
-- PART 4: PROJECT PROGRESS TABLE & IMPROVEMENT PLAN
-- ============================================================

-- Create Project_progress table
CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);

-- Populate Project_progress with improvement recommendations
INSERT INTO Project_progress
    (source_id, Address, Town, Province, Source_type, Improvement)
SELECT
    water_source.source_id,
    location.address,
    location.town_name,
    location.province_name,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30
            THEN CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM water_source
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN visits ON water_source.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (
    well_pollution.results != 'Clean'
    OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
    OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
);
-- Result: 25,398 improvement tasks generated
