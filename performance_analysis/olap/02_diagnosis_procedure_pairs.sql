
SET @StartTime = NOW(3);
SELECT
    d.icd10_code,
    p.cpt_code,
    COUNT(f.encounter_key) AS encounter_count
FROM fact_encounters f
JOIN bridge_encounter_diagnoses bd
    ON f.encounter_key = bd.encounter_key
JOIN bridge_encounter_procedures bp
    ON f.encounter_key = bp.encounter_key
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

SELECT CONCAT('Execution Time (ms): ', 
              TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000) AS ExecutionTime_ms;
