# src/data/departments.py
import logging
from src.connection import test_db_connection
from mysql.connector import Error

logger = logging.getLogger("departments_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def generate_departments():
    conn = None
    cur = None
    departments = [
        (1, "Cardiology Unit", 3, 20),
        (2, "Internal Medicine", 2, 30),
        (3, "Emergency", 1, 45)
    ]
    try:
        conn = test_db_connection()
        if not conn:
            logger.error("Database connection failed.")
            return []

        cur = conn.cursor()
        cur.executemany(
            "INSERT INTO departments (department_id, department_name, floor, capacity) VALUES (%s, %s, %s, %s)",
            departments
        )
        conn.commit()
        logger.info(f"Inserted {len(departments)} departments.")
        return [d[0] for d in departments]

    except Error as e:
        logger.error(f"MySQL error: {e}")
        return []
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()
