import pymysql
from pymysql import Error
import os
from dotenv import load_dotenv
import logging

# Load environment variables
load_dotenv()

# Configure logger
logger = logging.getLogger("db_connection")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

# Database credentials
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_TIMEOUT = int(os.getenv("DB_TIMEOUT", 10))


def get_connection():
    """Create and return a MySQL connection."""
    print("Attempting to connect to the database...")
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            connect_timeout=DB_TIMEOUT
        )
        logger.info(f"Successfully connected to database: {DB_NAME}")
        return conn

    except Error as e:
        logger.error(f"Error connecting to MySQL: {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error connecting to MySQL: {e}")
        return None


def test_db_connection():
    """Test function to verify the database connection and list tables."""
    conn = None
    cur = None
    try:
        conn = get_connection()
        if not conn:
            return

        cur = conn.cursor()

        cur.execute("SELECT VERSION();")
        version = cur.fetchone()[0]
        logger.info(f"MySQL Server Version: {version}")

        cur.execute("SELECT DATABASE();")
        current_db = cur.fetchone()[0]
        logger.info(f"Current Database: {current_db}")

        cur.execute("SHOW DATABASES;")
        databases = cur.fetchall()
        logger.info("Databases available on server:")
        for db in databases:
            logger.info(f" - {db[0]}")

        cur.execute("SHOW TABLES;")
        tables = cur.fetchall()
        logger.info(f"Tables in {DB_NAME}:")
        for table in tables:
            logger.info(f" - {table[0]}")

    except Error as e:
        logger.error(f"MySQL error: {e}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()
            logger.info("Database connection closed.")


if __name__ == "__main__":
    test_db_connection()