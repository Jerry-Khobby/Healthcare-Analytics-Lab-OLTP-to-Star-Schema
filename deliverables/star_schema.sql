CREATE TABLE dim_date (
  date_key INT PRIMARY KEY,
  calendar_date DATE,
  year INT,
  month INT,
  quarter INT
);

CREATE TABLE dim_patient (
  patient_key INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  gender CHAR(1),
  age_group VARCHAR(20)
  full_name varchar(20)
  mrn varchar(20)

);

CREATE TABLE dim_specialty (
  specialty_key INT AUTO_INCREMENT PRIMARY KEY,
  specialty_id INT,
  specialty_name VARCHAR(100)
);

CREATE TABLE dim_department (
  department_key INT AUTO_INCREMENT PRIMARY KEY,
  department_id INT,
  department_name VARCHAR(100)
);

CREATE TABLE dim_encounter_type (
  encounter_type_key INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(50)
);

CREATE TABLE fact_encounters (
  encounter_key INT AUTO_INCREMENT PRIMARY KEY,
  date_key INT,
  patient_key INT,
  specialty_key INT,
  department_key INT,
  encounter_type_key INT,
  encounter_count INT,
  total_allowed_amount DECIMAL(12,2),
  total_claim_amount DECIMAL(12,2),
  diagnosis_count INT,
  procedure_count INT,
  length_of_stay INT,
  FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
  FOREIGN KEY (patient_key) REFERENCES dim_patient(patient_key),
  FOREIGN KEY (specialty_key) REFERENCES dim_specialty(specialty_key),
  FOREIGN KEY (department_key) REFERENCES dim_department(department_key),
  FOREIGN KEY (encounter_type_key) REFERENCES dim_encounter_type(encounter_type_key)
);

CREATE TABLE dim_diagnosis (
  diagnosis_key INT AUTO_INCREMENT PRIMARY KEY,
  icd10_code VARCHAR(10),
  description VARCHAR(200)
);

CREATE TABLE dim_procedure (
  procedure_key INT AUTO_INCREMENT PRIMARY KEY,
  cpt_code VARCHAR(10),
  description VARCHAR(200)
);

CREATE TABLE bridge_encounter_diagnoses (
  encounter_key INT,
  diagnosis_key INT
);

CREATE TABLE bridge_encounter_procedures (
  encounter_key INT,
  procedure_key INT
);
