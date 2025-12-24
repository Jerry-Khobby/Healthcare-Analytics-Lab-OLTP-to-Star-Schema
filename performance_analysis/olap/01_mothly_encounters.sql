SET @StartTime = NOW(3);

SELECT
    d.year,
    d.month,
    s.specialty_name,
    et.type_name AS encounter_type,
    COUNT(f.encounter_key) AS total_encounters,
    COUNT(DISTINCT f.patient_key) AS unique_patients
FROM fact_encounters f
JOIN dim_date d
    ON f.date_key = d.date_key
JOIN dim_specialty s
    ON f.specialty_key = s.specialty_key
JOIN dim_encounter_type et
    ON f.encounter_type_key = et.encounter_type_key
GROUP BY
    d.year,
    d.month,
    s.specialty_name,
    et.type_name
ORDER BY
    d.year,
    d.month,
    s.specialty_name,
    et.type_name;

-- capture end time
SET @EndTime = NOW(3);

SELECT CONCAT('Execution Time (ms): ', 
              TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000) AS ExecutionTime_ms;
