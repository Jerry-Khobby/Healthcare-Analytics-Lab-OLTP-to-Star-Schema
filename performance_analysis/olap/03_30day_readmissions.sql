SET @StartTime = NOW(3);
WITH inpatient_encounters AS (
    SELECT
        f.encounter_key,
        f.patient_key,
        f.specialty_key,
        d.calendar_date AS admission_date,
        DATE_ADD(d.calendar_date, INTERVAL f.length_of_stay DAY) AS discharge_date
    FROM fact_encounters f
    JOIN dim_date d
        ON f.date_key = d.date_key
    WHERE f.encounter_type_key = 1  -- Inpatient
),
readmissions AS (
    SELECT
        a.encounter_key AS initial_encounter,
        b.encounter_key AS readmit_encounter,
        a.specialty_key
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
    ROUND(
        COUNT(DISTINCT r.readmit_encounter) /
        COUNT(DISTINCT i.encounter_key) * 100,
        2
    ) AS readmission_rate_percent
FROM inpatient_encounters i
JOIN dim_specialty s
    ON i.specialty_key = s.specialty_key
LEFT JOIN readmissions r
    ON i.encounter_key = r.initial_encounter
GROUP BY
    s.specialty_name
ORDER BY
    readmission_rate_percent DESC;
SET @EndTime = NOW(3);
-- Compute execution time in milliseconds
SELECT TIMESTAMPDIFF(MICROSECOND, @StartTime, @EndTime)/1000 AS ExecutionTime_ms;
