-- inserting into the date dimension from the oltp healthcare database 
INSERT INTO healthcare_olap.dim_date (date_key, calendar_date, year, month, quarter)
SELECT DISTINCT
  DATE_FORMAT(e.encounter_date, '%Y%m%d') AS date_key,
  DATE(e.encounter_date) AS calendar_date,
  YEAR(e.encounter_date),
  MONTH(e.encounter_date),
  QUARTER(e.encounter_date)
FROM healthcare_oltp.encounters e;


--inserting patient dimension from oltp patient table 
INSERT INTO healthcare_olap.dim_patient
(patient_id, full_name, gender, age_group, mrn)
SELECT
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS full_name,
  p.gender,
  CASE
    WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) >= 65 THEN '65+'
    WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) BETWEEN 45 AND 64 THEN '45-64'
    ELSE 'Under 45'
  END AS age_group,
  p.mrn
FROM healthcare_oltp.patients p;


-- specialty
INSERT INTO healthcare_olap.dim_specialty
(specialty_id, specialty_name)
SELECT
  s.specialty_id,
  s.specialty_name
FROM healthcare_oltp.specialties s;


--dimension department 
INSERT INTO healthcare_olap.dim_department
(department_id, department_name)
SELECT
  d.department_id,
  d.department_name
FROM healthcare_oltp.departments d;


--dimensional encounter 
INSERT INTO healthcare_olap.dim_encounter_type (type_name)
SELECT DISTINCT
  e.encounter_type
FROM healthcare_oltp.encounters e;


--dimension diagnosis 
INSERT INTO healthcare_olap.dim_diagnosis
(icd10_code, description)
SELECT
  d.icd10_code,
  d.icd10_description
FROM healthcare_oltp.diagnoses d;



--dimensional procedure 
INSERT INTO healthcare_olap.dim_procedure
(cpt_code, description)
SELECT
  p.cpt_code,
  p.cpt_description
FROM healthcare_oltp.procedures p;



--fact table insertions 
INSERT INTO healthcare_olap.fact_encounters (
  date_key,
  patient_key,
  specialty_key,
  department_key,
  encounter_type_key,
  encounter_count,
  total_allowed_amount,
  total_claim_amount,
  diagnosis_count,
  procedure_count,
  length_of_stay
)
SELECT
  DATE_FORMAT(e.encounter_date, '%Y%m%d') AS date_key,
  dp.patient_key,
  ds.specialty_key,
  dd.department_key,
  det.encounter_type_key,
  1 AS encounter_count,
  SUM(b.allowed_amount) AS total_allowed_amount,
  SUM(b.claim_amount) AS total_claim_amount,
  COUNT(DISTINCT ed.diagnosis_id) AS diagnosis_count,
  COUNT(DISTINCT ep.procedure_id) AS procedure_count,
  DATEDIFF(e.discharge_date, e.encounter_date) AS length_of_stay
FROM healthcare_oltp.encounters e

JOIN healthcare_olap.dim_patient dp
  ON dp.patient_id = e.patient_id

JOIN healthcare_oltp.providers pr
  ON pr.provider_id = e.provider_id

JOIN healthcare_olap.dim_specialty ds
  ON ds.specialty_id = pr.specialty_id

JOIN healthcare_olap.dim_department dd
  ON dd.department_id = e.department_id

JOIN healthcare_olap.dim_encounter_type det
  ON det.type_name = e.encounter_type

LEFT JOIN healthcare_oltp.billing b
  ON b.encounter_id = e.encounter_id

LEFT JOIN healthcare_oltp.encounter_diagnoses ed
  ON ed.encounter_id = e.encounter_id

LEFT JOIN healthcare_oltp.encounter_procedures ep
  ON ep.encounter_id = e.encounter_id

GROUP BY
  e.encounter_id,
  date_key,
  dp.patient_key,
  ds.specialty_key,
  dd.department_key,
  det.encounter_type_key,
  e.encounter_date,
  e.discharge_date;




---bridge table loads 


INSERT INTO healthcare_olap.bridge_encounter_diagnoses
(encounter_key, diagnosis_key)
SELECT
  fe.encounter_key,
  dd.diagnosis_key
FROM healthcare_oltp.encounter_diagnoses ed

JOIN healthcare_oltp.encounters e
  ON e.encounter_id = ed.encounter_id

JOIN healthcare_olap.fact_encounters fe
  ON fe.date_key = DATE_FORMAT(e.encounter_date, '%Y%m%d')
 AND fe.patient_key = (
     SELECT patient_key
     FROM healthcare_olap.dim_patient
     WHERE patient_id = e.patient_id
 )

JOIN healthcare_olap.dim_diagnosis dd
  ON dd.icd10_code = (
     SELECT icd10_code
     FROM healthcare_oltp.diagnoses
     WHERE diagnosis_id = ed.diagnosis_id
 );



--bridge table encounter_procedures 
INSERT INTO healthcare_olap.bridge_encounter_procedures
(encounter_key, procedure_key)
SELECT
  fe.encounter_key,
  dp.procedure_key
FROM healthcare_oltp.encounter_procedures ep

JOIN healthcare_oltp.encounters e
  ON e.encounter_id = ep.encounter_id

JOIN healthcare_olap.fact_encounters fe
  ON fe.date_key = DATE_FORMAT(e.encounter_date, '%Y%m%d')
 AND fe.patient_key = (
     SELECT patient_key
     FROM healthcare_olap.dim_patient
     WHERE patient_id = e.patient_id
 )

JOIN healthcare_olap.dim_procedure dp
  ON dp.cpt_code = (
     SELECT cpt_code
     FROM healthcare_oltp.procedures
     WHERE procedure_id = ep.procedure_id
 );



-- 1. Load dim_date
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_date.csv'
IGNORE
INTO TABLE dim_date
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(date_key, calendar_date, year, month, quarter);

-- 2. Load dim_patient
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_patient.csv'
IGNORE
INTO TABLE dim_patient
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(patient_key, patient_id, full_name, gender, age_group, mrn);

-- 3. Load dim_specialty
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_specialty.csv'
ignore
INTO TABLE dim_specialty
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(specialty_key, specialty_id, specialty_name);

-- 4. Load dim_department
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_department.csv'
IGNORE
INTO TABLE dim_department
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(department_key, department_id, department_name);

-- 5. Load dim_encounter_type
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_encounter_type.csv'
IGNORE
INTO TABLE dim_encounter_type
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(encounter_type_key, type_name);

-- 6. Load dim_diagnosis
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_diagnosis.csv'
IGNORE
INTO TABLE dim_diagnosis
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(diagnosis_key, icd10_code, description);

-- 7. Load dim_procedure
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_procedure.csv'
IGNORE
INTO TABLE dim_procedure
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(procedure_key, cpt_code, description);

-- 8. Load fact_encounters
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_encounters.csv'
REPLACE
INTO TABLE fact_encounters
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(encounter_key, date_key, patient_key, specialty_key, department_key, encounter_type_key, 
 encounter_count, total_allowed_amount, total_claim_amount, diagnosis_count, procedure_count, length_of_stay);

-- 9. Load bridge_encounter_diagnoses
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bridge_encounter_diagnoses.csv'
IGNORE
INTO TABLE bridge_encounter_diagnoses
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(encounter_key, diagnosis_key);

-- 10. Load bridge_encounter_procedures
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bridge_encounter_procedures.csv'
IGNORE
INTO TABLE bridge_encounter_procedures
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(encounter_key, procedure_key);