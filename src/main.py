import logging
from src.data_generation import (
    patients,
    specialties,
    departments,
    providers,
    diagnoses,
    procedures,
    encounters,
    encounter_diagnoses,
    encounter_procedures,
    billing
)
from src.config import *  

# Configure main logger
logger = logging.getLogger("data_orchestrator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def main():
    logger.info("Starting database population...")

    # Step 1: Insert static reference tables
    specialty_ids = specialties.generate_specialties()
    department_ids = departments.generate_departments()

    # Step 2: Insert dynamic tables
    provider_ids = providers.generate_providers(n=50)  # generate 50 providers
    patient_ids = patients.generate_patients(n=1000)  # generate 1000 patients

    # Step 3: Insert encounters and related tables
    encounter_ids = encounters.generate_encounters(patient_ids, provider_ids, n=1500)

    diagnosis_ids = diagnoses.generate_diagnoses()
    procedure_ids = procedures.generate_procedures()

    encounter_diagnoses.generate_encounter_diagnoses(encounter_ids, diagnosis_ids)
    encounter_procedures.generate_encounter_procedures(encounter_ids, procedure_ids)

    # Step 4: Insert billing
    billing.generate_billing(encounter_ids, n_per_encounter=1)

    logger.info("Database population completed successfully.")


if __name__ == "__main__":
    main()
