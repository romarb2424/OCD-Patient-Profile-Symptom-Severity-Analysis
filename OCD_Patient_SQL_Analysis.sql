-- ============================================================
-- PROJECT: OCD Patient Profile & Symptom Severity Analysis
-- FILE: OCD_Patient_SQL_Analysis.sql
-- DBMS: MySQL 8.0+
-- ============================================================
-- Business problem:
-- Provide a descriptive overview of the imported patient records:
-- demographics, recorded obsession/compulsion categories, Y-BOCS
-- component scores, diagnosis flags, and data quality.
-- This is descriptive analysis, not clinical advice or causal analysis.
--
-- IMPORTANT:
-- The current imported table previously showed 1,393 rows, while the
-- source was expected to contain 1,500. The reason for this difference
-- has not been verified. Review the CSV import log before concluding why.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ocd_analysis;
USE ocd_analysis;

-- Create table only if it does not already exist.
-- If your table already contains imported data, do NOT drop it.
CREATE TABLE IF NOT EXISTS ocd_patients (
    `Patient ID` INT NOT NULL,
    `Age` INT,
    `Gender` VARCHAR(30),
    `Ethnicity` VARCHAR(60),
    `Marital Status` VARCHAR(40),
    `Education Level` VARCHAR(60),
    `OCD Diagnosis Date` DATE,
    `Duration of Symptoms (months)` INT,
    `Previous Diagnoses` VARCHAR(100),
    `Family History of OCD` VARCHAR(10),
    `Obsession Type` VARCHAR(60),
    `Compulsion Type` VARCHAR(60),
    `Y-BOCS Score (Obsessions)` INT,
    `Y-BOCS Score (Compulsions)` INT,
    `Depression Diagnosis` VARCHAR(10),
    `Anxiety Diagnosis` VARCHAR(10),
    `Medications` VARCHAR(100),
    PRIMARY KEY (`Patient ID`)
);

-- ============================================================
-- SECTION 1: DATA QUALITY
-- ============================================================

-- Problem 1: Verify imported record count and ID uniqueness.
SELECT
    COUNT(*) AS total_records,
    COUNT(`Patient ID`) AS non_null_patient_ids,
    COUNT(DISTINCT `Patient ID`) AS unique_patient_ids
FROM ocd_patients;

-- Problem 2: Identify duplicate Patient IDs in the imported table.
-- Expected: zero rows if the primary key is enforced.
SELECT `Patient ID`, COUNT(*) AS id_count
FROM ocd_patients
GROUP BY `Patient ID`
HAVING COUNT(*) > 1;

-- Problem 3: Check missing values and invalid age / score values.
-- The 0-40 score range is the validation range used for this project.
SELECT
    COUNT(*) AS total_records,
    SUM(`Patient ID` IS NULL) AS missing_patient_ids,
    SUM(`Age` IS NULL) AS missing_ages,
    SUM(`Age` < 0 OR `Age` > 120) AS invalid_ages,
    SUM(`Y-BOCS Score (Obsessions)` < 0 OR `Y-BOCS Score (Obsessions)` > 40)
        AS invalid_obsession_scores,
    SUM(`Y-BOCS Score (Compulsions)` < 0 OR `Y-BOCS Score (Compulsions)` > 40)
        AS invalid_compulsion_scores
FROM ocd_patients;

-- Check missingness in two descriptive fields.
SELECT
    SUM(`Previous Diagnoses` IS NULL) AS missing_previous_diagnoses,
    SUM(`Medications` IS NULL) AS missing_medications
FROM ocd_patients;

-- Problem 4: Compare expected and imported row counts.
-- Expected count is 1,500 based on the working source-file expectation.
-- The difference is a discrepancy to investigate, not proof of cause.
SELECT
    1500 AS expected_records,
    COUNT(*) AS imported_records,
    1500 - COUNT(*) AS record_difference
FROM ocd_patients;

-- ============================================================
-- SECTION 2: BUSINESS ANALYSIS
-- ============================================================

-- Problem 5: What is the age profile of the imported records?
SELECT
    MIN(`Age`) AS youngest_age,
    MAX(`Age`) AS oldest_age,
    ROUND(AVG(`Age`), 2) AS average_age,
    COUNT(*) AS total_records
FROM ocd_patients;

-- Problem 6: How are records distributed by gender?
SELECT
    `Gender`,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Gender`
ORDER BY total_patients DESC;

-- Problem 7: How are records distributed by ethnicity?
SELECT
    `Ethnicity`,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Ethnicity`
ORDER BY total_patients DESC;

-- Problem 8: How are records distributed by marital status?
SELECT
    `Marital Status`,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Marital Status`
ORDER BY total_patients DESC;

-- Problem 9: How are records distributed by education level?
SELECT
    `Education Level`,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Education Level`
ORDER BY total_patients DESC;

-- Problem 10: Which obsession types are most frequently recorded?
SELECT
    `Obsession Type`,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Obsession Type`
ORDER BY total_patients DESC;

-- Problem 11: Which compulsion types are most frequently recorded?
SELECT
    `Compulsion Type`,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Compulsion Type`
ORDER BY total_patients DESC;

-- Problem 12: Summarize Y-BOCS component score ranges and averages.
SELECT
    MIN(`Y-BOCS Score (Obsessions)`) AS min_obsession_score,
    MAX(`Y-BOCS Score (Obsessions)`) AS max_obsession_score,
    ROUND(AVG(`Y-BOCS Score (Obsessions)`), 2) AS avg_obsession_score,
    MIN(`Y-BOCS Score (Compulsions)`) AS min_compulsion_score,
    MAX(`Y-BOCS Score (Compulsions)`) AS max_compulsion_score,
    ROUND(AVG(`Y-BOCS Score (Compulsions)`), 2) AS avg_compulsion_score
FROM ocd_patients;

-- Problem 13: Summarize recorded symptom duration in months.
SELECT
    MIN(`Duration of Symptoms (months)`) AS shortest_duration_months,
    MAX(`Duration of Symptoms (months)`) AS longest_duration_months,
    ROUND(AVG(`Duration of Symptoms (months)`), 2) AS average_duration_months
FROM ocd_patients;

-- Problem 14: How are previous diagnosis categories recorded?
SELECT
    COALESCE(`Previous Diagnoses`, 'Not Recorded') AS previous_diagnosis,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY COALESCE(`Previous Diagnoses`, 'Not Recorded')
ORDER BY total_patients DESC;

-- Problem 15: What are the recorded depression diagnosis flags?
SELECT
    `Depression Diagnosis` AS depression_diagnosis,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Depression Diagnosis`
ORDER BY total_patients DESC;

-- Additional descriptive query: anxiety diagnosis flags (already run in Workbench).
SELECT
    `Anxiety Diagnosis` AS anxiety_diagnosis,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Anxiety Diagnosis`
ORDER BY total_patients DESC;

-- Additional descriptive query: family history of OCD.
SELECT
    `Family History of OCD` AS family_history,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ocd_patients), 2) AS percentage
FROM ocd_patients
GROUP BY `Family History of OCD`
ORDER BY total_patients DESC;

-- Additional descriptive query: diagnosis-date trend by year and month.
SELECT
    YEAR(`OCD Diagnosis Date`) AS diagnosis_year,
    MONTH(`OCD Diagnosis Date`) AS diagnosis_month,
    COUNT(*) AS total_records
FROM ocd_patients
GROUP BY YEAR(`OCD Diagnosis Date`), MONTH(`OCD Diagnosis Date`)
ORDER BY diagnosis_year, diagnosis_month;

-- Additional subquery: records with obsession scores above the overall average.
SELECT
    `Patient ID`,
    `Y-BOCS Score (Obsessions)` AS obsession_score
FROM ocd_patients
WHERE `Y-BOCS Score (Obsessions)` > (
    SELECT AVG(`Y-BOCS Score (Obsessions)`)
    FROM ocd_patients
)
ORDER BY obsession_score DESC;

-- ============================================================
-- SECTION 3: REUSABLE REPORTING VIEW
-- ============================================================

CREATE OR REPLACE VIEW patient_summary AS
SELECT
    `Patient ID`,
    `Age`,
    `Gender`,
    `Ethnicity`,
    `Obsession Type`,
    `Compulsion Type`,
    `Y-BOCS Score (Obsessions)`,
    `Y-BOCS Score (Compulsions)`,
    `Depression Diagnosis`,
    `Anxiety Diagnosis`
FROM ocd_patients;

-- Test the view.
SELECT *
FROM patient_summary
LIMIT 10;

-- Example aggregate report from the view.
SELECT
    `Obsession Type`,
    COUNT(*) AS total_patients,
    ROUND(AVG(`Y-BOCS Score (Obsessions)`), 2) AS average_obsession_score
FROM patient_summary
GROUP BY `Obsession Type`
ORDER BY total_patients DESC;

-- ============================================================
-- SECTION 4: OPTIONAL WINDOW FUNCTION
-- ============================================================

-- Rank records by obsession score, highest first.
-- Tied scores receive the same rank. This is descriptive only.
SELECT
    `Patient ID`,
    `Age`,
    `Obsession Type`,
    `Y-BOCS Score (Obsessions)`,
    RANK() OVER (ORDER BY `Y-BOCS Score (Obsessions)` DESC) AS score_rank
FROM ocd_patients
ORDER BY score_rank
LIMIT 20;

-- ============================================================
-- END OF PROJECT
-- ============================================================
