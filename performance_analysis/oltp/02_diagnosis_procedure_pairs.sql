SET @StartTime = NOW(3);


SELECT 
    d.icd10_code AS ICD,
    p.cpt_code AS Procedure_Code,
    p.cpt_description AS ProcedureDescription,
    COUNT(DISTINCT e.encounter_id) AS Encounter_Count
FROM encounters e
JOIN encounter_diagnoses ed ON e.encounter_id = ed.encounter_id
JOIN diagnoses d ON ed.diagnosis_id = d.diagnosis_id
JOIN encounter_procedures ep ON e.encounter_id = ep.encounter_id
JOIN procedures p ON ep.procedure_id = p.procedure_id
GROUP BY d.icd10_code, p.cpt_code, p.cpt_description
ORDER BY Encounter_Count DESC;  -- optional, for top pairs


SET @EndTime = NOW(3);

-- Compute execution time in milliseconds
SELECT TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000 AS ExecutionTime_ms;
