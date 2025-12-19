# src/data/encounters.py
from faker import Faker
import random
import logging
from src.connection import test_db_connection
from mysql.connector import Error
from datetime import datetime, timedelta

logger = logging.getLogger("encounters_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

fake = Faker()

def generate_encounters(patient_ids, provider_ids, n=1000):
    conn = None
    cur = None
    encounter_ids = []

    try:
        conn = test_db_connection()
        if not conn:
            logger.error("Database connection failed.")
            return encounter_ids

        cur = conn.cursor()
        encounters = []
        for i in range(7001, 7001+n):
            patient_id = random.choice(patient_ids)
            provider_id = random.choice(provider_ids)
            encounter_type = random.choice(["Outpatient", "Inpatient", "ER"])
            encounter_date = fake.date_time_this_year(before_now=True, after_now=False)
            discharge_date = encounter_date + timedelta(hours=random.randint(1, 72))
            department_id = random.randint(1, 3)
            encounters.append((i, patient_id, provider_id, encounter_type, encounter_date, discharge_date, department_id))

        cur.executemany(
            "INSERT INTO encounters (encounter_id, patient_id, provider_id, encounter_type, encounter_date, discharge_date, department_id) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            encounters
        )
        conn.commit()
        encounter_ids = [e[0] for e in encounters]
        logger.info(f"Inserted {len(encounter_ids)} encounters.")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()

    return encounter_ids
