# src/data/procedures.py
import logging
from extraction.connection import get_connection
from pymysql import Error  

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
        (4003, "71020", "Chest X-ray"),
            (4004, "80053", "Comprehensive Metabolic Panel"),
    (4005, "85025", "Complete Blood Count"),
    (4006, "45378", "Colonoscopy"),
    (4007, "70450", "CT Scan Head"),
    (4008, "71045", "Portable Chest X-Ray"),
    (4009, "36415", "Venipuncture"),
    (4010, "93010", "EKG Interpretation")
    ]
    try:
        conn = get_connection()
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
        if cur: 
            cur.close()
        if conn: 
            conn.close()
