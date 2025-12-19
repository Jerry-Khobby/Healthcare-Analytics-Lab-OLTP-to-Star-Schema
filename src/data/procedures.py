# src/data/procedures.py
import logging
from src.connection import test_db_connection
from mysql.connector import Error

logger = logging.getLogger("procedures_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def generate_procedures():
    conn = None
    cur = None
    procedures = [
        (4001, "99213", "Office Visit"),
        (4002, "93000", "EKG"),
        (4003, "71020", "Chest X-ray")
    ]
    try:
        conn = test_db_connection()
        if not conn:
            logger.error("Database connection failed.")
            return []

        cur = conn.cursor()
        cur.executemany(
            "INSERT INTO procedures (procedure_id, cpt_code, cpt_description) VALUES (%s, %s, %s)",
            procedures
        )
        conn.commit()
        logger.info(f"Inserted {len(procedures)} procedures.")
        return [p[0] for p in procedures]

    except Error as e:
        logger.error(f"MySQL error: {e}")
        return []
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()
