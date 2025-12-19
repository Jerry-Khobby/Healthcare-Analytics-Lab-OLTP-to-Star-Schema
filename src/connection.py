import mysql.connector
from mysql.connector import Error
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
DB_HOST = os.getenv("HOSTNAME")
DB_USER = os.getenv("USER")
DB_PASSWORD = os.getenv("PASSWORD")
DB_NAME = os.getenv("DATABASE")
DB_PORT = int(os.getenv("PORT", 3306))
DB_TIMEOUT = int(os.getenv("DB_TIMEOUT", 10))


def get_connection():
    """Create and return a MySQL connection."""
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            connection_timeout=DB_TIMEOUT
        )
        if conn.is_connected():
            logger.info(f"Successfully connected to database: {DB_NAME}")
            return conn
        else:
            logger.error("Connection failed without raising an exception.")
            return None

    except Error as e:
        logger.error(f"Error connecting to MySQL: {e}")
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
    finally:
        if cur: cur.close()
        if conn and conn.is_connected():
            conn.close()
            logger.info("Database connection closed.")


if __name__ == "__main__":
    get_connection()
