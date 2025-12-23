-- Drop database if exists
DROP DATABASE IF EXISTS healthcare_oltp;

-- Create database
CREATE DATABASE IF NOT EXISTS healthcare_oltp;
USE healthcare_oltp;

-- Patients
CREATE TABLE if not exists patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender CHAR(1),
    mrn VARCHAR(20)
);

-- Specialties
CREATE TABLE if not exists specialties (
    specialty_id INT PRIMARY KEY,
    specialty_name VARCHAR(100),
    specialty_code VARCHAR(10)
);

-- Departments
CREATE TABLE if not exists departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    floor INT,
    capacity INT
);

-- Providers
CREATE TABLE if not exists providers (
    provider_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    credential VARCHAR(20),
    specialty_id INT,
    department_id INT
);

-- Encounters
CREATE TABLE  if not exists encounters (
    encounter_id INT PRIMARY KEY,
    patient_id INT,
    provider_id INT,
    encounter_type VARCHAR(50),
    encounter_date DATETIME,
    discharge_date DATETIME,
    department_id INT
);

-- Diagnoses
CREATE TABLE  if not exists diagnoses (
    diagnosis_id INT PRIMARY KEY,
    icd10_code VARCHAR(10),
    icd10_description VARCHAR(200)
);

-- Encounter Diagnoses
CREATE TABLE  if not exists encounter_diagnoses (
    encounter_diagnosis_id INT PRIMARY KEY,
    encounter_id INT,
    diagnosis_id INT,
    diagnosis_sequence INT
);

-- Procedures
CREATE TABLE  if not exists procedures (
    procedure_id INT PRIMARY KEY,
    cpt_code VARCHAR(10),
    cpt_description VARCHAR(200)
);

-- Encounter Procedures
CREATE TABLE  if not exists encounter_procedures (
    encounter_procedure_id INT PRIMARY KEY,
    encounter_id INT,
    procedure_id INT,
    procedure_date DATE
);

-- Billing
CREATE TABLE  if not exists billing (
    billing_id INT PRIMARY KEY,
    encounter_id INT,
    claim_amount DECIMAL(12, 2),
    allowed_amount DECIMAL(12, 2),
    claim_date DATE,
    claim_status VARCHAR(50)
);
