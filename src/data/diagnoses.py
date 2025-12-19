# src/data/diagnoses.py
import logging
from src.connection import test_db_connection
from mysql.connector import Error

logger = logging.getLogger("diagnoses_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def generate_diagnoses():
    conn = None
    cur = None
    diagnoses = [
        (3001, "I10", "Hypertension"),
        (3002, "E11.9", "Type 2 Diabetes"),
        (3003, "I50.9", "Heart Failure")
    ]
    try:
        conn = test_db_connection()
        if not conn:
            logger.error("Database connection failed.")
            return []

        cur = conn.cursor()
        cur.executemany(
            "INSERT INTO diagnoses (diagnosis_id, icd10_code, icd10_description) VALUES (%s, %s, %s)",
            diagnoses
        )
        conn.commit()
        logger.info(f"Inserted {len(diagnoses)} diagnoses.")
        return [d[0] for d in diagnoses]

    except Error as e:
        logger.error(f"MySQL error: {e}")
        return []
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()
