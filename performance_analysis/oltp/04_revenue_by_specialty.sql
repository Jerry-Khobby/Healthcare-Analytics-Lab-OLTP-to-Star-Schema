SET @StartTime = NOW(3);


SELECT 
    s.specialty_name AS Specialty_name,
    DATE_FORMAT(e.encounter_date, '%Y-%m') AS Encounter_Month,
    SUM(b.allowed_amount) AS Total_allowed
FROM billing b
JOIN encounters e ON b.encounter_id = e.encounter_id
JOIN providers p ON e.provider_id = p.provider_id
JOIN specialties s ON p.specialty_id = s.specialty_id
GROUP BY s.specialty_name, DATE_FORMAT(e.encounter_date, '%Y-%m')
ORDER BY Encounter_Month DESC, Total_allowed DESC;



SET @EndTime = NOW(3);

SELECT CONCAT('Execution Time (ms): ', 
              TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000) AS ExecutionTime_ms;