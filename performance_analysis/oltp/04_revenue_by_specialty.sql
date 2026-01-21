-- Record start time
SET @StartTime = NOW(3);

-- Your query
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

-- Record end time
SET @EndTime = NOW(3);

-- Compute execution time in milliseconds
SELECT TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000 AS ExecutionTime_ms;
