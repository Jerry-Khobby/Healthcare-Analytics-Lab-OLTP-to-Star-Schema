USE healthcare_oltp;

-- Unique constraints
ALTER TABLE patients
ADD CONSTRAINT uq_patients_mrn UNIQUE (mrn);

-- Providers foreign keys
ALTER TABLE providers
ADD CONSTRAINT fk_providers_specialty FOREIGN KEY (specialty_id)
    REFERENCES specialties (specialty_id),
ADD CONSTRAINT fk_providers_department FOREIGN KEY (department_id)
    REFERENCES departments (department_id);

-- Encounters foreign keys
ALTER TABLE encounters
ADD CONSTRAINT fk_encounters_patient FOREIGN KEY (patient_id)
    REFERENCES patients (patient_id),
ADD CONSTRAINT fk_encounters_provider FOREIGN KEY (provider_id)
    REFERENCES providers (provider_id),
ADD CONSTRAINT fk_encounters_department FOREIGN KEY (department_id)
    REFERENCES departments (department_id),
ADD INDEX idx_encounter_date (encounter_date);

-- Encounter Diagnoses foreign keys
ALTER TABLE encounter_diagnoses
ADD CONSTRAINT fk_enc_diag_encounter FOREIGN KEY (encounter_id)
    REFERENCES encounters (encounter_id),
ADD CONSTRAINT fk_enc_diag_diagnosis FOREIGN KEY (diagnosis_id)
    REFERENCES diagnoses (diagnosis_id);

-- Encounter Procedures foreign keys
ALTER TABLE encounter_procedures
ADD CONSTRAINT fk_enc_proc_encounter FOREIGN KEY (encounter_id)
    REFERENCES encounters (encounter_id),
ADD CONSTRAINT fk_enc_proc_procedure FOREIGN KEY (procedure_id)
    REFERENCES procedures (procedure_id);
    
-- Billing foreign key
ALTER TABLE billing
ADD CONSTRAINT fk_billing_encounter FOREIGN KEY (encounter_id)
    REFERENCES encounters (encounter_id),
ADD INDEX idx_claim_date (claim_date);
