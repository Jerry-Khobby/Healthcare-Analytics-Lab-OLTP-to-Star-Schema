CREATE DATABASE IF NOT EXISTS HealthCare_Analytics;
USE HealthCare_Analytics;


-- Dimension Tables

CREATE TABLE IF NOT EXISTS dim_date (
  date_key INT PRIMARY KEY,
  calendar_date DATE NOT NULL,
  year INT NOT NULL,
  month INT NOT NULL,
  quarter INT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_patient (
  patient_key INT PRIMARY KEY,
  patient_id INT NOT NULL,
  full_name VARCHAR(100),
  gender CHAR(1),
  age_group VARCHAR(20),
  mrn VARCHAR(20),

  CONSTRAINT uq_dim_patient_patient_id UNIQUE (patient_id),
  CONSTRAINT chk_dim_patient_gender
    CHECK (gender IN ('M','F') OR gender IS NULL)
);

CREATE TABLE IF NOT EXISTS dim_specialty (
  specialty_key INT PRIMARY KEY,
  specialty_id INT NOT NULL,
  specialty_name VARCHAR(100) NOT NULL,

  CONSTRAINT uq_dim_specialty_specialty_id UNIQUE (specialty_id)
);

CREATE TABLE IF NOT EXISTS dim_department (
  department_key INT PRIMARY KEY,
  department_id INT NOT NULL,
  department_name VARCHAR(100) NOT NULL,

  CONSTRAINT uq_dim_department_department_id UNIQUE (department_id)
);

CREATE TABLE IF NOT EXISTS dim_encounter_type (
  encounter_type_key INT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL,

  CONSTRAINT uq_dim_encounter_type_name UNIQUE (type_name)
);

CREATE TABLE IF NOT EXISTS dim_diagnosis (
  diagnosis_key INT PRIMARY KEY,
  icd10_code VARCHAR(10) NOT NULL,
  description VARCHAR(200),

  CONSTRAINT uq_dim_diagnosis_icd10 UNIQUE (icd10_code)
);

CREATE TABLE IF NOT EXISTS dim_procedure (
  procedure_key INT PRIMARY KEY,
  cpt_code VARCHAR(10) NOT NULL,
  description VARCHAR(200),

  CONSTRAINT uq_dim_procedure_cpt UNIQUE (cpt_code)
);


-- Fact Table

CREATE TABLE IF NOT EXISTS fact_encounters (
  encounter_key INT PRIMARY KEY,
  date_key INT NOT NULL,
  patient_key INT NOT NULL,
  specialty_key INT NOT NULL,
  department_key INT NOT NULL,
  encounter_type_key INT NOT NULL,
  encounter_count INT NOT NULL,
  total_allowed_amount DECIMAL(12,2),
  total_claim_amount DECIMAL(12,2),
  diagnosis_count INT,
  procedure_count INT,
  length_of_stay INT,

  CONSTRAINT fk_fact_date
    FOREIGN KEY (date_key)
    REFERENCES dim_date(date_key),

  CONSTRAINT fk_fact_patient
    FOREIGN KEY (patient_key)
    REFERENCES dim_patient(patient_key),

  CONSTRAINT fk_fact_specialty
    FOREIGN KEY (specialty_key)
    REFERENCES dim_specialty(specialty_key),

  CONSTRAINT fk_fact_department
    FOREIGN KEY (department_key)
    REFERENCES dim_department(department_key),

  CONSTRAINT fk_fact_encounter_type
    FOREIGN KEY (encounter_type_key)
    REFERENCES dim_encounter_type(encounter_type_key),

  CONSTRAINT chk_fact_encounter_count
    CHECK (encounter_count = 1),

  CONSTRAINT chk_fact_non_negative_amounts
    CHECK (
      total_allowed_amount >= 0
      AND total_claim_amount >= 0
    ),

  CONSTRAINT chk_fact_non_negative_counts
    CHECK (
      diagnosis_count >= 0
      AND procedure_count >= 0
    )
);


-- Bridge Tables
CREATE TABLE IF NOT EXISTS bridge_encounter_diagnoses (
  encounter_key INT NOT NULL,
  diagnosis_key INT NOT NULL,

  CONSTRAINT pk_bridge_encounter_diagnoses
    PRIMARY KEY (encounter_key, diagnosis_key),

  CONSTRAINT fk_bridge_diag_encounter
    FOREIGN KEY (encounter_key)
    REFERENCES fact_encounters(encounter_key),

  CONSTRAINT fk_bridge_diag_diagnosis
    FOREIGN KEY (diagnosis_key)
    REFERENCES dim_diagnosis(diagnosis_key)
);

CREATE TABLE IF NOT EXISTS bridge_encounter_procedures (
  encounter_key INT NOT NULL,
  procedure_key INT NOT NULL,

  CONSTRAINT pk_bridge_encounter_procedures
    PRIMARY KEY (encounter_key, procedure_key),

  CONSTRAINT fk_bridge_proc_encounter
    FOREIGN KEY (encounter_key)
    REFERENCES fact_encounters(encounter_key),

  CONSTRAINT fk_bridge_proc_procedure
    FOREIGN KEY (procedure_key)
    REFERENCES dim_procedure(procedure_key)
);







----Insert Data ------
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
