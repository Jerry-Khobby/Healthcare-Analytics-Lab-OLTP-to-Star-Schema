from faker import Faker
import random
import logging
from mysql.connector import Error
from src.connection import get_connection

logger = logging.getLogger("patients_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

fake = Faker()

def generate_patients(n=1000):
    conn = None
    cur = None
    patient_ids = []

    try:
        conn = get_connection()
        if not conn:
            logger.error("Database connection failed.")
            return patient_ids

        cur = conn.cursor()
        patients = [
            (
                i,
                fake.first_name(),
                fake.last_name(),
                fake.date_of_birth(minimum_age=0, maximum_age=100),
                random.choice(["M", "F"]),
                f"MRN{i:06d}"
            )
            for i in range(1, n+1)
        ]

        cur.executemany(
            "INSERT INTO patients (patient_id, first_name, last_name, date_of_birth, gender, mrn) "
            "VALUES (%s, %s, %s, %s, %s, %s)", patients
        )
        conn.commit()
        patient_ids = [p[0] for p in patients]
        logger.info(f"Inserted {len(patient_ids)} patients successfully.")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()
    return patient_ids
