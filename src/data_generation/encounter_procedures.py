# src/data/encounter_procedures.py
from faker import Faker
import random
import logging
from src.connection import get_connection
from mysql.connector import Error
from datetime import date, timedelta

logger = logging.getLogger("encounter_procedures_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

fake = Faker()

def generate_encounter_procedures(encounter_ids, procedure_ids):
    conn = None
    cur = None
    enc_proc_ids = []

    try:
        conn = get_connection()
        if not conn:
            logger.error("Database connection failed.")
            return enc_proc_ids

        cur = conn.cursor()
        enc_procs = []
        for i, enc_id in enumerate(encounter_ids, start=9001):
            proc_id = random.choice(procedure_ids)
            proc_date = fake.date_this_year(before_today=True, after_today=False)
            enc_procs.append((i, enc_id, proc_id, proc_date))

        cur.executemany(
            "INSERT INTO encounter_procedures (encounter_procedure_id, encounter_id, procedure_id, procedure_date) "
            "VALUES (%s, %s, %s, %s)",
            enc_procs
        )
        conn.commit()
        enc_proc_ids = [e[0] for e in enc_procs]
        logger.info(f"Inserted {len(enc_proc_ids)} encounter procedures.")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()

    return enc_proc_ids
