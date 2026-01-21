import sys
from pathlib import Path
from datetime import datetime

# Add parent directory to Python path so we can import src module
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import logging
from src.data_generation import (
    patients,
    specialties,
    department,
    providers,
    diagnoses,
    procedures,
    encounters,
    encounter_diagnoses,
    encounter_procedures,
    billing
)
from extraction.config.scales import * 

# Create logs directory if it doesn't exist
log_dir = Path(__file__).parent.parent / "logs"
log_dir.mkdir(exist_ok=True)

# Generate log filename with timestamp
log_filename = log_dir / f"data_generation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

# Configure main logger
logger = logging.getLogger("data_orchestrator")
logger.setLevel(logging.INFO)

# Console handler
console_handler = logging.StreamHandler()
console_formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
console_handler.setFormatter(console_formatter)
logger.addHandler(console_handler)

# File handler
file_handler = logging.FileHandler(log_filename, encoding='utf-8')
file_formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
file_handler.setFormatter(file_formatter)
logger.addHandler(file_handler)

logger.info(f"Logging to file: {log_filename}")

def clear_existing_data():
    """Clear all existing data from tables in correct order (respecting foreign keys)"""
    from src.connection import get_connection
    
    logger.info("Clearing existing data...")
    conn = get_connection()
    if not conn:
        logger.error("Could not connect to database to clear data")
        return False
    
    try:
        cur = conn.cursor()
        
        # Delete in reverse order of dependencies
        tables = [
            "billing",
            "encounter_procedures", 
            "encounter_diagnoses",
            "encounters",
            "patients",
            "providers",
            "procedures",
            "diagnoses",
            "departments",
            "specialties"
        ]
        
        for table in tables:
            cur.execute(f"DELETE FROM {table}")
            logger.info(f"Cleared table: {table}")
        
        conn.commit()
        logger.info("All data cleared successfully")
        return True
        
    except Exception as e:
        logger.error(f"Error clearing data: {e}")
        return False
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


def main():
    logger.info("Starting database population...")
    
    # Clear existing data first
    if not clear_existing_data():
        logger.error("Failed to clear existing data. Exiting.")
        return
    
    logger.info("Generating specialties...")
    specialty_ids = specialties.generate_specialties()
    logger.info(f"Generated {len(specialty_ids)} specialties")
    
    logger.info("Generating departments...")
    department_ids = department.generate_departments()
    logger.info(f"Generated {len(department_ids)} departments")
    
    logger.info("Generating providers...")
    provider_ids = providers.generate_providers(n=PROVIDERS)
    logger.info(f"Generated {len(provider_ids)} providers")
    
    logger.info("Generating patients...")
    patient_ids = patients.generate_patients(n=PATIENTS)
    logger.info(f"Generated {len(patient_ids)} patients")

    logger.info("Generating encounters...")
    encounter_ids = encounters.generate_encounters(patient_ids, provider_ids, n=ENCOUNTERS)
    logger.info(f"Generated {len(encounter_ids)} encounters")

    logger.info("Generating diagnoses...")
    diagnosis_ids = diagnoses.generate_diagnoses()
    logger.info(f"Generated {len(diagnosis_ids)} diagnoses")
    
    logger.info("Generating procedures...")
    procedure_ids = procedures.generate_procedures()
    logger.info(f"Generated {len(procedure_ids)} procedures")

    logger.info("Generating encounter diagnoses...")
    encounter_diagnoses.generate_encounter_diagnoses(encounter_ids, diagnosis_ids)
    
    logger.info("Generating encounter procedures...")
    encounter_procedures.generate_encounter_procedures(encounter_ids, procedure_ids)

    logger.info("Generating billing records...")
    billing.generate_billing(encounter_ids, n_per_encounter=1)

    logger.info("Database population completed successfully.")


if __name__ == "__main__":
    main()