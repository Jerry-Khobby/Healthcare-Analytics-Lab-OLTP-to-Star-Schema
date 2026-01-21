-- DATABASE


DROP DATABASE IF EXISTS healthcare_oltp;
CREATE DATABASE IF NOT EXISTS healthcare_oltp;
USE healthcare_oltp;


-- MASTER TABLES


CREATE TABLE IF NOT EXISTS patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender CHAR(1),
    mrn VARCHAR(20),

    CONSTRAINT uq_patients_mrn UNIQUE (mrn)
);

CREATE TABLE IF NOT EXISTS specialties (
    specialty_id INT PRIMARY KEY,
    specialty_name VARCHAR(100),
    specialty_code VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    floor INT,
    capacity INT
);

CREATE TABLE IF NOT EXISTS providers (
    provider_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    credential VARCHAR(20),
    specialty_id INT,
    department_id INT,

    CONSTRAINT fk_providers_specialty
        FOREIGN KEY (specialty_id)
        REFERENCES specialties (specialty_id),

    CONSTRAINT fk_providers_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);

-- TRANSACTION TABLES

CREATE TABLE IF NOT EXISTS encounters (
    encounter_id INT PRIMARY KEY,
    patient_id INT,
    provider_id INT,
    encounter_type VARCHAR(50),
    encounter_date DATETIME,
    discharge_date DATETIME,
    department_id INT,

    CONSTRAINT fk_encounters_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id),

    CONSTRAINT fk_encounters_provider
        FOREIGN KEY (provider_id)
        REFERENCES providers (provider_id),

    CONSTRAINT fk_encounters_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id),

    INDEX idx_encounter_date (encounter_date)
);

CREATE TABLE IF NOT EXISTS diagnoses (
    diagnosis_id INT PRIMARY KEY,
    icd10_code VARCHAR(10),
    icd10_description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS encounter_diagnoses (
    encounter_diagnosis_id INT PRIMARY KEY,
    encounter_id INT,
    diagnosis_id INT,
    diagnosis_sequence INT,

    CONSTRAINT fk_enc_diag_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES encounters (encounter_id),

    CONSTRAINT fk_enc_diag_diagnosis
        FOREIGN KEY (diagnosis_id)
        REFERENCES diagnoses (diagnosis_id)
);

CREATE TABLE IF NOT EXISTS procedures (
    procedure_id INT PRIMARY KEY,
    cpt_code VARCHAR(10),
    cpt_description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS encounter_procedures (
    encounter_procedure_id INT PRIMARY KEY,
    encounter_id INT,
    procedure_id INT,
    procedure_date DATE,

    CONSTRAINT fk_enc_proc_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES encounters (encounter_id),

    CONSTRAINT fk_enc_proc_procedure
        FOREIGN KEY (procedure_id)
        REFERENCES procedures (procedure_id)
);

CREATE TABLE IF NOT EXISTS billing (
    billing_id INT PRIMARY KEY,
    encounter_id INT,
    claim_amount DECIMAL(12, 2),
    allowed_amount DECIMAL(12, 2),
    claim_date DATE,
    claim_status VARCHAR(50),

    CONSTRAINT fk_billing_encounter
        FOREIGN KEY (encounter_id)
        REFERENCES encounters (encounter_id),

    INDEX idx_claim_date (claim_date)
);
