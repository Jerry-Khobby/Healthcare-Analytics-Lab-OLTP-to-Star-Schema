ALTER TABLE fact_encounters
  ADD CONSTRAINT fk_fact_date
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
  ADD CONSTRAINT fk_fact_patient
    FOREIGN KEY (patient_key) REFERENCES dim_patient(patient_key),
  ADD CONSTRAINT fk_fact_specialty
    FOREIGN KEY (specialty_key) REFERENCES dim_specialty(specialty_key),
  ADD CONSTRAINT fk_fact_department
    FOREIGN KEY (department_key) REFERENCES dim_department(department_key),
  ADD CONSTRAINT fk_fact_encounter_type
    FOREIGN KEY (encounter_type_key) REFERENCES dim_encounter_type(encounter_type_key);

ALTER TABLE bridge_encounter_diagnoses
  ADD CONSTRAINT fk_bridge_diag_encounter
    FOREIGN KEY (encounter_key) REFERENCES fact_encounters(encounter_key),
  ADD CONSTRAINT fk_bridge_diag_diagnosis
    FOREIGN KEY (diagnosis_key) REFERENCES dim_diagnosis(diagnosis_key),
  ADD CONSTRAINT pk_bridge_encounter_diagnoses
    PRIMARY KEY (encounter_key, diagnosis_key);

ALTER TABLE bridge_encounter_procedures
  ADD CONSTRAINT fk_bridge_proc_encounter
    FOREIGN KEY (encounter_key) REFERENCES fact_encounters(encounter_key),
  ADD CONSTRAINT fk_bridge_proc_procedure
    FOREIGN KEY (procedure_key) REFERENCES dim_procedure(procedure_key),
  ADD CONSTRAINT pk_bridge_encounter_procedures
    PRIMARY KEY (encounter_key, procedure_key);




ALTER TABLE dim_patient
  ADD CONSTRAINT chk_patient_gender
    CHECK (gender IN ('M', 'F'));

ALTER TABLE fact_encounters
  ADD CONSTRAINT chk_encounter_count
    CHECK (encounter_count = 1);

ALTER TABLE fact_encounters
  ADD CONSTRAINT chk_non_negative_amounts
    CHECK (
      total_allowed_amount >= 0
      AND total_claim_amount >= 0
    );

ALTER TABLE fact_encounters
  ADD CONSTRAINT chk_non_negative_counts
    CHECK (
      diagnosis_count >= 0
      AND procedure_count >= 0
    );

