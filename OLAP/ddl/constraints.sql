ALTER TABLE dim_patient
  ADD CONSTRAINT uq_dim_patient_patient_id UNIQUE (patient_id),
  ADD CONSTRAINT chk_dim_patient_gender
    CHECK (gender IN ('M','F') OR gender IS NULL);
ALTER TABLE dim_specialty
  ADD CONSTRAINT uq_dim_specialty_specialty_id UNIQUE (specialty_id);
ALTER TABLE dim_department
  ADD CONSTRAINT uq_dim_department_department_id UNIQUE (department_id);
ALTER TABLE dim_encounter_type
  ADD CONSTRAINT uq_dim_encounter_type_name UNIQUE (type_name);
ALTER TABLE dim_diagnosis
  ADD CONSTRAINT uq_dim_diagnosis_icd10 UNIQUE (icd10_code);
ALTER TABLE dim_procedure
  ADD CONSTRAINT uq_dim_procedure_cpt UNIQUE (cpt_code);
ALTER TABLE fact_encounters
  ADD CONSTRAINT fk_fact_date
    FOREIGN KEY (date_key)
    REFERENCES dim_date(date_key),

  ADD CONSTRAINT fk_fact_patient
    FOREIGN KEY (patient_key)
    REFERENCES dim_patient(patient_key),

  ADD CONSTRAINT fk_fact_specialty
    FOREIGN KEY (specialty_key)
    REFERENCES dim_specialty(specialty_key),

  ADD CONSTRAINT fk_fact_department
    FOREIGN KEY (department_key)
    REFERENCES dim_department(department_key),

  ADD CONSTRAINT fk_fact_encounter_type
    FOREIGN KEY (encounter_type_key)
    REFERENCES dim_encounter_type(encounter_type_key);


ALTER TABLE fact_encounters
  ADD CONSTRAINT chk_fact_encounter_count
    CHECK (encounter_count = 1),

  ADD CONSTRAINT chk_fact_non_negative_amounts
    CHECK (
      total_allowed_amount >= 0
      AND total_claim_amount >= 0
    ),

  ADD CONSTRAINT chk_fact_non_negative_counts
    CHECK (
      diagnosis_count >= 0
      AND procedure_count >= 0
    );


ALTER TABLE bridge_encounter_diagnoses
  ADD CONSTRAINT pk_bridge_encounter_diagnoses
    PRIMARY KEY (encounter_key, diagnosis_key),

  ADD CONSTRAINT fk_bridge_diag_encounter
    FOREIGN KEY (encounter_key)
    REFERENCES fact_encounters(encounter_key),

  ADD CONSTRAINT fk_bridge_diag_diagnosis
    FOREIGN KEY (diagnosis_key)
    REFERENCES dim_diagnosis(diagnosis_key);


ALTER TABLE bridge_encounter_procedures
  ADD CONSTRAINT pk_bridge_encounter_procedures
    PRIMARY KEY (encounter_key, procedure_key),

  ADD CONSTRAINT fk_bridge_proc_encounter
    FOREIGN KEY (encounter_key)
    REFERENCES fact_encounters(encounter_key),

  ADD CONSTRAINT fk_bridge_proc_procedure
    FOREIGN KEY (procedure_key)
    REFERENCES dim_procedure(procedure_key);
