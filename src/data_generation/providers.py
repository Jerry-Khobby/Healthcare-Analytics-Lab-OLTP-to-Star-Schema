# src/data/providers.py
from faker import Faker
import random
import logging
from src.connection import get_connection
from pymysql import Error  

logger = logging.getLogger("providers_generator")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

fake = Faker()

def generate_providers(n=150):
    conn = None
    cur = None
    provider_ids = []

    try:
        conn = get_connection()
        if not conn:
            logger.error("Database connection failed.")
            return provider_ids

        cur = conn.cursor()
        providers = [
            (
                i,
                fake.first_name(),
                fake.last_name(),
                random.choice(["MD", "DO", "RN", "PA"]),
                random.randint(1, 10),  # specialty_id
                random.randint(1, 6)   # department_id
            ) for i in range(101, 101+n)
        ]
        cur.executemany(
            "INSERT INTO providers (provider_id, first_name, last_name, credential, specialty_id, department_id) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            providers
        )
        conn.commit()
        provider_ids = [p[0] for p in providers]
        logger.info(f"Inserted {len(provider_ids)} providers.")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    finally:
        if cur: 
            cur.close()
        if conn: 
            conn.close()

    return provider_ids
