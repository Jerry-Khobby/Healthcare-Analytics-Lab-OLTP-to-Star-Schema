SET @StartTime = NOW(3);
WITH inpatient_encounters AS (
    SELECT 
        f.encounter_key,
        f.patient_key,
        f.specialty_key,
        d.calendar_date AS admission_date,
        DATE_ADD(d.calendar_date, INTERVAL f.length_of_stay DAY) AS discharge_date
    FROM fact_encounters f
    JOIN dim_date d ON f.date_key = d.date_key
    JOIN dim_encounter_type et ON f.encounter_type_key = et.encounter_type_key
    WHERE et.type_name = 'Inpatient'
),

readmissions AS (
    SELECT 
        a.patient_key,
        a.specialty_key,
        a.encounter_key AS first_encounter,
        b.encounter_key AS readmit_encounter
    FROM inpatient_encounters a
    JOIN inpatient_encounters b
      ON a.patient_key = b.patient_key
     AND b.admission_date > a.discharge_date
     AND b.admission_date <= DATE_ADD(a.discharge_date, INTERVAL 30 DAY)
)

SELECT 
    s.specialty_name,
    COUNT(DISTINCT r.readmit_encounter) AS readmissions,
    COUNT(DISTINCT i.encounter_key) AS total_inpatient_encounters,
    ROUND(COUNT(DISTINCT r.readmit_encounter) / COUNT(DISTINCT i.encounter_key) * 100, 2) AS readmission_rate_percent
FROM inpatient_encounters i
JOIN dim_specialty s ON i.specialty_key = s.specialty_key
LEFT JOIN readmissions r ON i.encounter_key = r.first_encounter
GROUP BY s.specialty_name
ORDER BY readmission_rate_percent DESC;
SET @EndTime = NOW(3);

SELECT CONCAT('Execution Time (ms): ', 
              TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000) AS ExecutionTime_ms;