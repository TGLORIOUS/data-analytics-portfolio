-- ============================================================
-- MAJI NDOGO WATER CRISIS: PART 1 - DATA EXPLORATION
-- Project: Clustering data to unveil Maji Ndogo's water crisis
-- Tools: MySQL, SQLite
-- ============================================================

-- SECTION 1: DATA CLEANING
-- Update employee emails
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');

-- Fix phone numbers with trailing spaces
UPDATE employee
SET phone_number = TRIM(phone_number);

-- Verify phone number length
SELECT LENGTH(phone_number) FROM employee;

-- SECTION 2: HONOURING THE WORKERS
-- Count employees per town
SELECT 
    town_name,
    COUNT(*) AS num_employees
FROM employee
GROUP BY town_name
ORDER BY num_employees DESC;

-- Top 3 field surveyors by number of visits
SELECT 
    assigned_employee_id,
    COUNT(*) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY number_of_visits DESC
LIMIT 3;

-- Get contact details of top 3 surveyors
SELECT 
    employee_name,
    email,
    phone_number
FROM employee
WHERE assigned_employee_id IN (1, 2, 3);

-- SECTION 3: ANALYSING LOCATIONS
-- Records per town
SELECT 
    COUNT(*) AS records_per_town,
    town_name
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;

-- Records per province
SELECT 
    COUNT(*) AS records_per_province,
    province_name
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC;

-- Records per province and town (sorted)
SELECT 
    province_name,
    town_name,
    COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name ASC, records_per_town DESC;

-- Urban vs Rural split
SELECT 
    COUNT(*) AS num_sources,
    location_type
FROM location
GROUP BY location_type;

-- Rural percentage calculation
SELECT 23740 / (15910 + 23740) * 100 AS rural_percentage;

-- SECTION 4: DIVING INTO WATER SOURCES
-- Total people surveyed
SELECT SUM(number_of_people_served) AS total_population
FROM water_source;

-- Count of each water source type
SELECT 
    type_of_water_source,
    COUNT(*) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;

-- Average people per source type
SELECT 
    type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS ave_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY ave_people_per_source DESC;

-- Total population per source type with percentages
SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    ROUND(SUM(number_of_people_served) / 27628140 * 100, 0) AS percentage
FROM water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;
