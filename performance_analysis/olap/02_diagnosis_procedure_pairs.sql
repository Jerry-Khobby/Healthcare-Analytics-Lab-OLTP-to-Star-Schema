SET @StartTime = NOW(3);
SELECT
    d.icd10_code,
    p.cpt_code,
    COUNT(*) AS encounter_count
FROM bridge_encounter_diagnoses bd
JOIN bridge_encounter_procedures bp
    ON bd.encounter_key = bp.encounter_key
JOIN dim_diagnosis d
    ON bd.diagnosis_key = d.diagnosis_key
JOIN dim_procedure p
    ON bp.procedure_key = p.procedure_key
GROUP BY
    d.icd10_code,
    p.cpt_code
ORDER BY
    encounter_count DESC;
SET @EndTime = NOW(3);
-- Compute execution time in milliseconds
SELECT TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000 AS ExecutionTime_ms;
