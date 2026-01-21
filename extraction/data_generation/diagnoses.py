# src/data/diagnoses.py
import logging
from extraction.connection import get_connection
from pymysql import Error  

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
        (3003, "I50.9", "Heart Failure"),
            (3004, "J45.909", "Asthma"),
    (3005, "N18.9", "Chronic Kidney Disease"),
    (3006, "E78.5", "Hyperlipidemia"),
    (3007, "I25.10", "Coronary Artery Disease"),
    (3008, "J18.9", "Pneumonia"),
    (3009, "M54.5", "Low Back Pain"),
    (3010, "R07.9", "Chest Pain")
    ]
    try:
        conn = get_connection()
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
        if cur: 
            cur.close()
        if conn:
            conn.close()
