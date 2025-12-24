CREATE DATABASE IF NOT EXISTS HealthCare_Analytics;
USE HealthCare_Analytics;


CREATE TABLE if not exists  dim_date (
  date_key INT PRIMARY KEY,
  calendar_date DATE NOT NULL,
  year INT NOT NULL,
  month INT NOT NULL,
  quarter INT NOT NULL
);

CREATE TABLE  if not exists dim_patient (
  patient_key INT  PRIMARY KEY,
  patient_id INT NOT NULL,
  full_name VARCHAR(100),
  gender CHAR(1),
  age_group VARCHAR(20),
  mrn VARCHAR(20)
);

CREATE TABLE  if not exists dim_specialty (
  specialty_key INT  PRIMARY KEY,
  specialty_id INT NOT NULL,
  specialty_name VARCHAR(100) NOT NULL
);

CREATE TABLE if not exists dim_department (
  department_key INT  PRIMARY KEY,
  department_id INT NOT NULL,
  department_name VARCHAR(100) NOT NULL
);

CREATE TABLE if not exists dim_encounter_type (
  encounter_type_key INT  PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL
);

CREATE TABLE if not exists  dim_diagnosis (
  diagnosis_key INT  PRIMARY KEY,
  icd10_code VARCHAR(10) NOT NULL,
  description VARCHAR(200)
);

CREATE TABLE if not exists dim_procedure (
  procedure_key INT  PRIMARY KEY,
  cpt_code VARCHAR(10) NOT NULL,
  description VARCHAR(200)
);

CREATE TABLE if not exists  fact_encounters (
  encounter_key INT  PRIMARY KEY,
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
  length_of_stay INT
);



CREATE TABLE if not exists bridge_encounter_diagnoses (
  encounter_key INT NOT NULL,
  diagnosis_key INT NOT NULL
);

CREATE TABLE if not exists bridge_encounter_procedures (
  encounter_key INT NOT NULL,
  procedure_key INT NOT NULL
);
