# src/data/billing.py
import random
import logging
from datetime import date, timedelta
from src.connection import get_connection
from mysql.connector import Error

logger = logging.getLogger("billing_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def generate_billing(encounter_ids, n_per_encounter=1):
    conn = None
    cur = None
    billing_ids = []

    try:
        conn = get_connection()
        if not conn:
            logger.error("Database connection failed.")
            return billing_ids

        cur = conn.cursor()
        billings = []
        i_counter = 14001

        for enc_id in encounter_ids:
            for _ in range(n_per_encounter):
                claim_amount = round(random.uniform(50, 5000), 2)
                allowed_amount = round(claim_amount * random.uniform(0.7, 1.0), 2)
                claim_date = date.today() - timedelta(days=random.randint(0, 365))
                status = random.choice(["Paid", "Pending", "Denied"])
                billings.append((i_counter, enc_id, claim_amount, allowed_amount, claim_date, status))
                i_counter += 1

        cur.executemany(
            "INSERT INTO billing (billing_id, encounter_id, claim_amount, allowed_amount, claim_date, claim_status) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            billings
        )
        conn.commit()
        billing_ids = [b[0] for b in billings]
        logger.info(f"Inserted {len(billing_ids)} billing records.")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    finally:
        if cur: cur.close()
        if conn and conn.is_connected(): conn.close()

    return billing_ids
