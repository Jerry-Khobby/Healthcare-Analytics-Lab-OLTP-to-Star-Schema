SET @StartTime = NOW(3);

SELECT 
    s.specialty_name,
    COUNT(*) AS readmission_count
FROM encounters e1
JOIN encounters e2 
    ON e1.patient_id = e2.patient_id
    AND e2.encounter_date > e1.discharge_date
    AND e2.encounter_date <= DATE_ADD(e1.discharge_date, INTERVAL 30 DAY)
JOIN providers p 
    ON e1.provider_id = p.provider_id
JOIN specialties s 
    ON p.specialty_id = s.specialty_id
WHERE e1.encounter_type = 'Inpatient'
  AND e2.encounter_type = 'Inpatient'
GROUP BY s.specialty_name
ORDER BY readmission_count DESC;



SET @EndTime = NOW(3);

SELECT CONCAT('Execution Time (ms): ', 
              TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000) AS ExecutionTime_ms;