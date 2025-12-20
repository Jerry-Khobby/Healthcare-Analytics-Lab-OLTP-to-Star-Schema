# src/data/encounter_diagnoses.py
import random
import logging
from src.connection import get_connection
from mysql.connector import Error

logger = logging.getLogger("encounter_diagnoses_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def generate_encounter_diagnoses(encounter_ids, diagnosis_ids):
    conn = None
    cur = None
    enc_diag_ids = []

    try:
        conn = get_connection()
        if not conn:
            logger.error("Database connection failed.")
            return enc_diag_ids

        cur = conn.cursor()
        enc_diags = []
        for i, enc_id in enumerate(encounter_ids, start=8001):
            diagnosis_id = random.choice(diagnosis_ids)
            sequence = 1
            enc_diags.append((i, enc_id, diagnosis_id, sequence))

        cur.executemany(
            "INSERT INTO encounter_diagnoses (encounter_diagnosis_id, encounter_id, diagnosis_id, diagnosis_sequence) "
            "VALUES (%s, %s, %s, %s)",
            enc_diags
        )
        conn.commit()
        enc_diag_ids = [e[0] for e in enc_diags]
        logger.info(f"Inserted {len(enc_diag_ids)} encounter diagnoses.")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()

    return enc_diag_ids
