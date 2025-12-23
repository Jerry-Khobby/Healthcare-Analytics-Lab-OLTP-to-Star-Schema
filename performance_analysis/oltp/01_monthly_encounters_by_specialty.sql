SET @StartTime = NOW(3);

SELECT 
    DATE_FORMAT(e.encounter_date, '%Y-%m') AS month,
    s.specialty_name,
    e.encounter_type,
    COUNT(e.encounter_id) AS total_encounters,
    COUNT(DISTINCT e.patient_id) AS unique_patients
FROM encounters e
JOIN providers p ON e.provider_id = p.provider_id
JOIN specialties s ON p.specialty_id = s.specialty_id
GROUP BY 
    DATE_FORMAT(e.encounter_date, '%Y-%m'),
    s.specialty_name,
    e.encounter_type
ORDER BY 
    month DESC,
    specialty_name,
    encounter_type;

SET @EndTime = NOW(3);

SELECT CONCAT('Execution Time (ms): ', 
              TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000) AS ExecutionTime_ms;
