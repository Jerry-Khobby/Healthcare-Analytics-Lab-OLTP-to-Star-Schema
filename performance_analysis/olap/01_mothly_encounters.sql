SET @StartTime = NOW(3);
SELECT
    d.year,
    d.month,
    s.specialty_name,
    f.encounter_type_key,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT f.patient_key) AS unique_patients
FROM fact_encounters f
JOIN dim_date d
    ON f.date_key = d.date_key
JOIN dim_specialty s
    ON f.specialty_key = s.specialty_key
GROUP BY
    d.year,
    d.month,
    s.specialty_name,
    f.encounter_type_key
ORDER BY
    d.year,
    d.month,
    s.specialty_name,
    f.encounter_type_key;
SET @EndTime = NOW(3);
-- Compute execution time in milliseconds
SELECT TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000 AS ExecutionTime_ms;
