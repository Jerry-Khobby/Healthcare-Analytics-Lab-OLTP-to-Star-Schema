import mysql.connector 
from mysql.connector import Error
import os
from dotenv import load_dotenv


load_dotenv()

# get the database credentials 

DB_HOST = os.getenv("HOSTNAME")
DB_USER = os.getenv("USER")  
DB_PASSWORD = os.getenv("PASSWORD")
DB_NAME = os.getenv("DATABASE")
DB_PORT = int(os.getenv("PORT",3306))
DB_TIMEOUT = int(os.getenv("DB_TIMEOUT", 10))


def test_db_connection():
    connection = None

    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            connection_timeout=DB_TIMEOUT
        )

        if connection.is_connected():
            print("Database connection established successfully")

            cursor = connection.cursor()

            # Server version
            cursor.execute("SELECT VERSION();")
            version = cursor.fetchone()[0]
            print("MySQL Server Version:", version)

            # Current database
            cursor.execute("SELECT DATABASE();")
            current_db = cursor.fetchone()[0]
            print("Current Database:", current_db)

            # Show all databases
            cursor.execute("SHOW DATABASES;")
            databases = cursor.fetchall()
            print("Databases available on server:")
            for db in databases:
                print(" -", db[0])

            # Show tables in current database
            cursor.execute("SHOW TABLES;")
            tables = cursor.fetchall()
            print(f"Tables in {DB_NAME}:")
            for table in tables:
                print(" -", table[0])

            cursor.close()

    except Error as e:
        print("Failed to connect to MySQL")
        print("Error:", e)

    finally:
        if connection and connection.is_connected():
            connection.close()
            print("Database connection closed")


if __name__ == "__main__":
    test_db_connection()