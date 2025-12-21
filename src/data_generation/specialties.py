# src/data/specialties.py
import logging
from src.connection import get_connection
from pymysql import Error  

logger = logging.getLogger("specialties_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def generate_specialties():
    conn = None
    cur = None
    specialties = [
        (1, "Cardiology", "CARD"),
        (2, "Internal Medicine", "IM"),
        (3, "Emergency", "ER"),
    (4, "Family Medicine", "FM"),
    (5, "Neurology", "NEURO"),
    (6, "Orthopedics", "ORTHO"),
    (7, "Pediatrics", "PEDS"),
    (8, "Oncology", "ONC"),
    (9, "Radiology", "RAD"),
    (10, "General Surgery", "GS")
    ]
    try:
        conn = get_connection()
        if not conn:
            logger.error("Database connection failed.")
            return []

        cur = conn.cursor()
        cur.executemany(
            "INSERT INTO specialties (specialty_id, specialty_name, specialty_code) VALUES (%s, %s, %s)",
            specialties
        )
        conn.commit()
        logger.info(f"Inserted {len(specialties)} specialties.")
        return [s[0] for s in specialties]

    except Error as e:
        logger.error(f"MySQL error: {e}")
        return []
    finally:
        if cur: 
            cur.close()
        if conn: 
            conn.close()
